# frozen_string_literal: true

module Lms
  class Biblios < Lms::Base
    helpers Lms::QueryParams::BiblioParams
    helpers Lms::QueryParams::BiblioItemParams

    resources :biblios do
      desc 'Biblios List'
      params do
        use :pagination, per_page: 25
        optional :isbn, type: String, allow_blank: false
        optional :title, type: String, allow_blank: false
        optional :author_id, type: Integer, allow_blank: false
        optional :publisher_id, type: Integer, allow_blank: false
        optional :subject_id, type: Integer, allow_blank: false
        optional :edition_id, type: Integer, allow_blank: false
        optional :series_statement_volume, type: String, allow_blank: false
      end

      get do
        biblios = Biblio.all
        biblios = biblios.where('lower(isbn) like ?', "%#{params[:isbn].downcase}%") if params[:isbn].present?
        if params[:title].present?
          biblios = biblios.where('lower(biblios.title) like ?', "%#{params[:title].downcase}%")
        end
        if params[:series_statement_volume].present?
          biblios = biblios.where('lower(series_statement_volume) like ?',
                                  "%#{params[:series_statement_volume].downcase}%")
        end
        if params[:author_id].present?
          author = Author.find(params[:author_id])
          unless author.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Author not found' },
                                    @current_library, false)
            error!('Author not found', HTTP_CODE[:NOT_FOUND])
          end
          biblios = biblios.joins(:author_biblios).where('author_biblios.author_id = ?', params[:author_id])
        end

        if params[:publisher_id].present?
          publication = BiblioPublication.find(params[:publisher_id])
          unless publication.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Publisher not found' },
                                    @current_library, false)
            error!('Publisher not found', HTTP_CODE[:NOT_FOUND])
          end
          biblios = biblios.where(biblio_publication: publication)
        end

        if params[:subject_id].present?
          subject = BiblioSubject.find(params[:subject_id])
          unless subject.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Subject not found' },
                                    @current_library, false)
            error!('Subject not found', HTTP_CODE[:NOT_FOUND])
          end
          biblios = biblios.joins(:biblio_subject_biblios).where('biblio_subject_biblios.biblio_subject_id',
                                                                 params[:subject_id])
        end

        if params[:edition_id].present?
          edition = BiblioEdition.find(params[:edition_id])
          unless edition.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Edition not found' },
                                    @current_library, false)
            error!('Edition not found', HTTP_CODE[:NOT_FOUND])
          end
          biblios = biblios.where(biblio_edition: edition)
        end
        LmsLogJob.perform_later(request.headers.merge(params:),
                                { status_code: HTTP_CODE[:OK] },
                                @current_library, true)
        Lms::Entities::BiblioDetails.represent(paginate(biblios.order(id: :desc)))
      end

      desc 'Create biblio'
      params do
        use :biblio_create_params
      end

      post do
        params_except_images = params.except(:image_file, :table_of_content_file)
        staff = @current_library.staffs.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                  @current_library,
                                  false)
          error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
        end


        if params[:date_of_publication].present?
          params[:date_of_publication] = DateTime.new(params[:date_of_publication], 1, 1)
        end

        item_type = ItemType.find_by(id: params[:item_type_id])
        unless item_type.present?
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Item type not found' },
                                  staff, false)
          error!('Item type not found', HTTP_CODE[:NOT_FOUND])
        end

        if params[:biblio_classification_source_id].present?
          biblio_classification_source = BiblioClassificationSource.find_by(id: params[:biblio_classification_source_id])
          unless biblio_classification_source.present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_FOUND],
                                      error: 'Biblio classification source not found' },
                                    staff, false)
            error!('Biblio classification source not found', HTTP_CODE[:NOT_FOUND])
          end
        end


        if params[:biblio_edition_id].present?
          biblio_edition = BiblioEdition.find_by(id: params[:biblio_edition_id])
          unless biblio_edition.present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio edition not found' },
                                    staff, false)
            error!('Biblio edition not found', HTTP_CODE[:NOT_FOUND])
          end
        end

        all_author_ids = []

        params[:author_ids]&.each do |id|
          author = Author.find_by(id:)
          unless author.present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Author not found' },
                                    staff, false)
            error!('Author not found', HTTP_CODE[:NOT_FOUND])
          end
          all_author_ids << { author_id: id, responsibility: 'Author' }
        end

        params[:editor_ids]&.each do |id|
          editor = Author.find_by(id:)
          unless editor.present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Editor not found' },
                                    staff, false)
            error!('Editor not found', HTTP_CODE[:NOT_FOUND])
          end
          all_author_ids << { author_id: id, responsibility: 'Editor' }
        end

        params[:translator_ids]&.each do |id|
          translator = Author.find_by(id:)
          unless translator.present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Translator not found' },
                                    staff, false)
            error!('Translator not found', HTTP_CODE[:NOT_FOUND])
          end
          all_author_ids << { author_id: id, responsibility: 'Translator' }
        end

        params[:contributor_ids]&.each do |id|
          contributor = Author.find_by(id:)
          unless contributor.present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Contributor not found' },
                                    staff, false)
            error!('Contributor not found', HTTP_CODE[:NOT_FOUND])
          end
          all_author_ids << { author_id: id, responsibility: 'Contributor' }
        end

        if params[:biblio_subject_biblios_attributes].present?
          params[:biblio_subject_biblios_attributes].each do |biblio_subject_biblio|
            biblio_subject = BiblioSubject.find_by(id: biblio_subject_biblio[:biblio_subject_id])
            next if biblio_subject.present?

            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio subject not found' },
                                    staff, false)
            error!('Biblio subject not found', HTTP_CODE[:NOT_FOUND])
          end
        end
        if params[:biblio_publication_id].present?
          biblio_publication = BiblioPublication.find_by(id: params[:biblio_publication_id])
          unless biblio_publication.present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio publication not found' },
                                    staff, false)
            error!('Biblio publication not found', HTTP_CODE[:NOT_FOUND])
          end
        end

        declared_params = declared(params, include_missing: false)
        params_in_biblio_attrs = declared_params.except(:staff_id, :author_ids, :editor_ids, :translator_ids,
                                                        :contributor_ids)
        all_associated_params = params_in_biblio_attrs.merge(created_by_id: staff.id, author_biblios_attributes: all_author_ids)
        biblio = Biblio.new(all_associated_params)
        if biblio.save!
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:CREATED]},
                                  staff, true)
          Lms::Entities::BiblioDetails.represent(biblio)
        end
      end

      route_param :id do
        desc 'Biblio details'
        get do
          biblio = Biblio.find_by(id: params[:id])
          unless biblio.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio not found' },
                                    @current_library, false)
            error!('Biblio not found', HTTP_CODE[:NOT_FOUND])
          end
          Lms::Entities::BiblioDetails.represent(biblio)
        end

        desc 'Update biblio'
        params do
          use :biblio_update_params
        end
        put do
          params_except_images = params.except(:image_file, :table_of_content_file)
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    @current_library,
                                    false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end

          if params[:date_of_publication].present?
            params[:date_of_publication] = DateTime.new(params[:date_of_publication], 1, 1)
          end

          biblio = Biblio.find_by(id: params[:id])
          unless biblio.present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio not found' },
                                    staff, false)
            error!('Biblio not found', HTTP_CODE[:NOT_FOUND])
          end

          item_type = ItemType.find_by(id: params[:item_type_id])
          unless item_type.present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Item type not found' },
                                    staff, false)
            error!('Item type not found', HTTP_CODE[:NOT_FOUND])
          end

          if params[:biblio_classification_source_id].present?
            biblio_classification_source = BiblioClassificationSource.find_by(id: params[:biblio_classification_source_id])
            unless biblio_classification_source.present?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_FOUND],
                                        error: 'Biblio classification source not found' },
                                      staff, false)
              error!('Biblio classification source not found', HTTP_CODE[:NOT_FOUND])
            end
          end

          author_biblios_attributes = []
          if params[:author_ids].present?
            current_author_ids = biblio.author_biblios.pluck(:author_id)

            # add new author_biblio
            (params[:author_ids] - current_author_ids)&.each do |author_id|
              author = Author.find_by(id: author_id)
              unless author.present?
                LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                        { status_code: HTTP_CODE[:NOT_FOUND], error: 'Author not found' },
                                        staff, false)
                error!("Author with #{author_id} not found", HTTP_CODE[:NOT_FOUND])
              end
              author_biblios_attributes << { author_id:, responsibility: 'Author' }
            end

            # remove author_biblio
            (current_author_ids - params[:author_ids])&.each do |author_id|
              author_biblios_attributes << { id: biblio.author_biblios.find_by(author_id:).id, _destroy: true }
            end
          end

          params[:editor_ids]&.each do |id|
            editor = Author.find_by(id:)
            unless editor.present?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Editor not found' },
                                      staff, false)
              error!('Editor not found', HTTP_CODE[:NOT_FOUND])
            end
            author_biblios_attributes << { author_id: id, responsibility: 'Editor' }
          end

          params[:translator_ids]&.each do |id|
            translator = Author.find_by(id:)
            unless translator.present?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Translator not found' },
                                      staff, false)
              error!('Translator not found', HTTP_CODE[:NOT_FOUND])
            end
            author_biblios_attributes << { author_id: id, responsibility: 'Translator' }
          end

          params[:contributor_ids]&.each do |id|
            contributor = Author.find_by(id:)
            unless contributor.present?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Contributor not found' },
                                      staff, false)
              error!('Contributor not found', HTTP_CODE[:NOT_FOUND])
            end
            author_biblios_attributes << { author_id: id, responsibility: 'Contributor' }
          end

          if params[:biblio_subject_biblios_attributes].present?
            current_subject_ids = biblio.biblio_subject_biblios.pluck(:biblio_subject_id)
            removed_subject_ids = current_subject_ids - params[:biblio_subject_biblios_attributes].pluck(:biblio_subject_id)
            params[:biblio_subject_biblios_attributes].each do |bsb|
              next if current_subject_ids.include?(bsb[:biblio_subject_id])

              if removed_subject_ids.present? && removed_subject_ids.include?(bsb[:biblio_subject_id])
                bsb.merge!(id: biblio.biblio_subject_biblios.find_by(biblio_subject_id: bsb[:biblio_subject_id]),
                           _destroy: true)
              else
                biblio_subject = BiblioSubject.find_by(id: bsb[:biblio_subject_id])
                unless biblio_subject.present?
                  LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                          { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio subject not found' },
                                          staff, false)
                  error!("Biblio subject #{bsb[:biblio_subject_id]} not found", HTTP_CODE[:NOT_FOUND])
                end
              end
            end
          end
          if params[:biblio_edition_id].present?
            biblio_edition = BiblioEdition.find_by(id: params[:biblio_edition_id])
            unless biblio_edition.present?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio edition not found' },
                                      staff, false)
              error!('Biblio edition not found', HTTP_CODE[:NOT_FOUND])
            end
          end

          if params[:biblio_publication_id].present?
            biblio_publication = BiblioPublication.find_by(id: params[:biblio_publication_id])
            unless biblio_publication.present?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio publication not found' },
                                      staff, false)
              error!('Biblio publication not found', HTTP_CODE[:NOT_FOUND])
            end
          end
          declared_params = declared(params, include_missing: false)
          Rails.logger.info("------declared_params-----#{declared_params}")

          biblio.update!(declared_params.except(:staff_id, :author_ids, :editor_ids, :translator_ids, :contributor_ids)
                                        .merge(updated_by_id: staff.id, author_biblios_attributes:))
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:OK] },
                                  staff, true)
          Lms::Entities::BiblioDetails.represent(biblio)
        end

        desc 'Biblio availability Paper biblio in all libraries or not'

        get :available_biblio_library_dropdown do
          biblio = Biblio.find(params[:id])
          error!('Biblio not found', HTTP_CODE[:NOT_FOUND]) unless biblio.present?
          biblio_library = BiblioLibrary.where('biblio_id = ? AND available_quantity > ?', biblio.id, 0)

          Lms::Entities::BiblioLibraryAvailable.represent(biblio_library)
        end

        resources :biblio_items do

          desc 'Create Multiple biblio item'
          params do
            use :multiple_biblio_item_create_params
          end
          post 'multiple' do
            params_except_images = params.except(:preview_file, :full_ebook_file, :table_of_content_file)
            staff = @current_library.staffs.library.find_by(id: params[:staff_id])
            unless staff.present?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                      @current_library, false)
              error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
            end
            biblio = Biblio.find_by(id: params[:id])
            unless biblio.present?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio not found' },
                                      staff, false)
              error!('Biblio not found', HTTP_CODE[:NOT_FOUND])
            end
            created_biblio_items = []
            params[:biblio_item_create_params].each do |biblio_item_param|
              validate_params = BiblioItemManagement::ValidateBiblioItem.call(request_params: biblio_item_param,
                                                                              biblio:,
                                                                              current_library: @current_library)
              unless validate_params.success?
                LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                        { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: validate_params.error.to_s },
                                        staff, false)
                error!(validate_params.error.to_s, HTTP_CODE[:NOT_ACCEPTABLE])
              end
              if params[:item_collection_type] == 'department'
                if biblio_item_param[:central_accession_no].nil?
                  error!('Central Accession No. is required', HTTP_CODE[:NOT_ACCEPTABLE])
                end
                department_biblio_item = DepartmentBiblioItem.where(library: @current_library).find_by(central_accession_no: biblio_item_param[:central_accession_no])
                if department_biblio_item.nil?
                  error!("department biblio item not found for accession no#{biblio_item_param[:central_accession_no]}", HTTP_CODE[:NOT_ACCEPTABLE])
                end
                if department_biblio_item&.biblio_item_id.present?
                  error!('Already added to biblio_item', HTTP_CODE[:NOT_ACCEPTABLE])
                end
              end
              # debugger
              custom_params = {
                barcode: biblio_item_param[:barcode],
                central_accession_no: biblio_item_param[:central_accession_no],
                accession_no: biblio_item_param[:accession_no],
                biblio_item_type: params[:biblio_item_type],
                item_collection_type: params[:item_collection_type],
                permanent_library_location_id: params[:permanent_library_location_id],
                current_library_location_id: params[:current_library_location_id],
                shelving_library_location_id: params[:shelving_library_location_id],
                price: params[:price],
                full_call_number: params[:full_call_number],
                note: params[:note],
                copy_number: biblio_item_param[:copy_number],
                not_for_loan: params[:not_for_loan],
                date_accessioned: params[:date_accessioned],
                library_id: @current_library.id,
                created_by_id: staff.id
              }

              biblio_item = biblio.biblio_items.create!(custom_params)
              created_biblio_items << biblio_item
              # debugger


              LmsLogJob.perform_later(request.headers.merge(biblio_item_param),
                                      { status_code: HTTP_CODE[:OK], error: '' },
                                      staff, true)
              if params[:item_collection_type] == 'department'
                department_biblio_item.update!(biblio_item_id: biblio_item.id)
              end
            end
            biblio.update!(preview_file: params[:preview_file],
                           full_ebook_file: params[:full_ebook_file])
            Lms::Entities::BiblioItems.represent(created_biblio_items)
          end


          desc 'Create a biblio item'
          params do
            use :biblio_item_create_params
          end

          post do
            params_except_images = params.except(:preview_file, :full_ebook_file, :table_of_content_file)
            staff = @current_library.staffs.library.find_by(id: params[:staff_id])
            unless staff.present?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                      @current_library, false)
              error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
            end

            biblio = Biblio.find_by(id: params[:id])
            unless biblio.present?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio not found' },
                                      staff, false)
              error!('Biblio not found', HTTP_CODE[:NOT_FOUND])
            end
            validate_params = BiblioItemManagement::ValidateBiblioItem.call(request_params: params,
                                                                            biblio:,
                                                                            current_library: @current_library)
            unless validate_params.success?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: validate_params.error.to_s },
                                      staff, false)
              error!(validate_params.error.to_s, HTTP_CODE[:NOT_ACCEPTABLE])
            end

            error!('item_collection_type is required', HTTP_CODE[:NOT_ACCEPTABLE]) if params[:item_collection_type].nil?

            if params[:item_collection_type] == 'department' || params[:item_collection_type] == 'existing'
              if params[:central_accession_no].nil?
                error!('Central Accession No. is required', HTTP_CODE[:NOT_ACCEPTABLE])
              end
              department_biblio_item = DepartmentBiblioItem.where(library: @current_library).find_by(central_accession_no: params[:central_accession_no])
              if !department_biblio_item.present? && params[:item_collection_type] != 'existing'
                error!('Record not found in DPL accession_no registration list', HTTP_CODE[:NOT_FOUND])
              end

              if department_biblio_item&.biblio_item_id.present?
                error!('Already added to biblio_item', HTTP_CODE[:NOT_ACCEPTABLE])
              end
            end

            biblio_item = biblio.biblio_items.create!(declared(params)
                                                        .except(:staff_id, :preview_file, :full_ebook_file)
                                                        .merge(library_id: @current_library.id,
                                                               created_by_id: staff.id))
            biblio.update!(preview_file: params[:preview_file], full_ebook_file: params[:full_ebook_file])

            if params[:item_collection_type] == 'department'
              department_biblio_item.update!(biblio_item_id: biblio_item.id)
            end

            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
            Lms::Entities::BiblioItems.represent(biblio_item)
          end

          desc 'Update multiple bibliographic items'
          params do
            use :multiple_biblio_item_update_params
          end

          put :update_multiple do
            params_except_images = params.except(:preview_file, :full_ebook_file)
            staff = @current_library.staffs.library.find_by(id: params[:staff_id])
            unless staff.present?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                      @current_library, false)
              error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
            end

            biblio = Biblio.find_by(id: params[:id])

            if biblio.item_type.option_value == 'OB'
              error!('item should not be created under Online books ', HTTP_CODE[:NOT_FOUND])
            end

            unless biblio.present?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio not found' },
                                      staff, false)
              error!('Biblio not found', HTTP_CODE[:NOT_FOUND])
            end

            validate_params = BiblioItemManagement::ValidateBiblioItem.call(request_params: params,
                                                                            biblio:,
                                                                            current_library: @current_library)
            unless validate_params.success?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: validate_params.error.to_s },
                                      staff, false)
              error!(validate_params.error.to_s, HTTP_CODE[:NOT_ACCEPTABLE])
            end
            updated_biblio_items = []
            selected_biblio_items = biblio.biblio_items.where(id: params[:biblio_item_ids])

            updated_biblio_items = selected_biblio_items.map do |biblio_item|
              biblio_item.update!(declared(params)
                                    .except(:staff_id, :preview_file, :full_ebook_file, :biblio_item_ids)
                                    .merge(library_id: @current_library.id, created_by_id: staff.id))
              biblio_item.reload  # Reload the object to get the updated attributes
            end

            biblio.update!(preview_file: params[:preview_file], full_ebook_file: params[:full_ebook_file])
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
            Lms::Entities::BiblioItems.represent(updated_biblio_items)
          end

          route_param :biblio_item_id do
            desc 'Update a biblio item'
            params do
              use :biblio_item_update_params
            end

            put do
              params_except_images = params.except(:preview_file, :full_ebook_file, :table_of_content_file)

              staff = @current_library.staffs.library.find_by(id: params[:staff_id])
              unless staff.present?
                LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                        { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                        @current_library, false)
                error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
              end

              biblio = Biblio.find_by(id: params[:id])
              unless biblio.present?
                LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                        { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio not found' },
                                        staff, false)
                error!('Biblio not found', HTTP_CODE[:NOT_FOUND])
              end

              biblio_item = biblio.biblio_items.find_by(id: params[:biblio_item_id],
                                                        library_id: @current_library.id)
              unless biblio_item.present?
                LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                        { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio item not found' },
                                        staff, false)
                error!('Biblio item not found', HTTP_CODE[:NOT_FOUND])
              end
              unless biblio_item.biblio_item_type == params[:biblio_item_type]
                LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                        { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio item type is invalid' },
                                        staff, false)
                error!('Biblio item type is invalid', HTTP_CODE[:NOT_ACCEPTABLE])
              end
              validate_params = BiblioItemManagement::ValidateBiblioItem.call(request_params: params,
                                                                              biblio:,
                                                                              current_library: @current_library)
              unless validate_params.success?
                LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                        { status_code: HTTP_CODE[:NOT_FOUND], error: validate_params.error.to_s },
                                        staff, false)
                error!(validate_params.error.to_s, HTTP_CODE[:NOT_ACCEPTABLE])
              end

              biblio_item.update(declared(params, include_missing: false)
                                   .except(:staff_id, :preview_file, :full_ebook_file)
                                   .merge(updated_by_id: staff.id))
              biblio.update!(preview_file: params[:preview_file], full_ebook_file: params[:full_ebook_file])

              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:OK] },
                                      staff, true)
              Lms::Entities::BiblioItems.represent(biblio_item)
            end
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Lms
  class BiblioAuthors < Lms::Base
    helpers Lms::QueryParams::AuthorParams
    resources :authors do
      desc 'Biblio author dropdown'

      get 'dropdown' do
        authors = Author.not_deleted.order(first_name: :asc)
        Lms::Entities::BiblioAuthorDropdown.represent(authors)
      end
      desc 'Search author'
      params do
        use :pagination, max_per_page: 25
        requires :search_term, type: String
      end

      get 'search' do
        authors = Author.not_deleted.where('lower(first_name) like :search_term or lower(middle_name) like :search_term
                                           or lower(last_name) like :search_term or bn_first_name like :search_term
                                           or bn_middle_name like :search_term or bn_last_name like :search_term',
                                           search_term: "%#{params[:search_term].downcase}%")
        Lms::Entities::AuthorSearch.represent(authors)
      end

      desc 'Create author'
      params do
        use :author_create_params
      end

      post do
        library_staff = @current_library.staffs.library.find_by(id: params[:staff_id])
        unless library_staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not valid for this library' },
                                  @current_library, false)
          error!('Staff not valid for this library', HTTP_CODE[:NOT_FOUND])
        end
        author = Author.not_deleted.find_by('first_name = ? and (middle_name = ?  OR middle_name IS NULL)
                                             and (last_name = ?  or last_name IS NULL) and (dob = ? OR dob IS NULL)',
                                            params[:first_name], params[:middle_name], params[:last_name],
                                            params[:dob])
        if author.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:CONFLICT], error: 'Author already exists' },
                                  library_staff, false)
          status HTTP_CODE[:CONFLICT]
          Lms::Entities::AuthorDetails.represent(author)
        else
          author = Author.new(declared(params, include_missing: false).except(:staff_id)
                                                                      .merge!(created_by_id: library_staff.id))
          if author.save!
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:CREATED] },
                                    library_staff, true)
            Lms::Entities::AuthorDetails.represent(author)
          end
        end
      end

      route_param :id do
        desc 'Update author'
        params do
          use :author_update_params
        end

        put do
          library_staff = @current_library.staffs.library.find_by(id: params[:staff_id])
          unless library_staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not valid for this library' },
                                    @current_library,
                                    false)
            error!('Staff not valid for this library', HTTP_CODE[:NOT_FOUND])
          end

          author = Author.not_deleted.find_by(id: params[:id])
          unless author.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Author not found' },
                                    library_staff,
                                    false)
            error!('Author not found', HTTP_CODE[:NOT_FOUND])
          end

          existing_author = Author.not_deleted.where.not(id: params[:id]).find_by('first_name = ? and (middle_name = ?  OR middle_name IS NULL)
                                             and (last_name = ?  or last_name IS NULL) and (dob = ? OR dob IS NULL)',
                                              params[:first_name], params[:middle_name], params[:last_name],
                                              params[:dob])
          if existing_author.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:CONFLICT], error: 'Author already exists' },
                                    library_staff, false)
            error!('Author already exists', HTTP_CODE[:CONFLICT])
          end


          author.update!(declared(params, include_missing: false).except(:staff_id)
                                                                 .merge!(updated_by_id: library_staff.id))
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  library_staff, true)
          Lms::Entities::AuthorDetails.represent(author)
        end

        desc 'author delete'
        params do
          use :author_delete_params
        end
        delete do
          library_staff = @current_library.staffs.library.find_by(id: params[:staff_id])
          unless library_staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not valid for this library' },
                                    @current_library,
                                    false)
            error!('Staff not valid for this library', HTTP_CODE[:NOT_FOUND])
          end
          author = Author.not_deleted.find_by(id: params[:id])
          unless author.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Author not found' },
                                    library_staff,
                                    false)
            error!('Author not found', HTTP_CODE[:NOT_FOUND])
          end
          unless author.author_biblios.blank?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Has associated biblios' },
                                    library_staff,
                                    false)
            error!('Has associated biblios', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          if author.update!(is_deleted: true, updated_by_id: library_staff.id, deleted_at: DateTime.now)
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    library_staff, true)
            Lms::Entities::AuthorDetails.represent(author)
          end
        end
      end
    end
  end
end

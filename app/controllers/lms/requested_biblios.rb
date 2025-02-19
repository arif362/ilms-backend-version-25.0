# frozen_string_literal: true

module Lms
  class RequestedBiblios < Lms::Base
    helpers Lms::QueryParams::RequestBiblioParams
    resources :requested_biblios do
      desc 'request for a biblio'
      params do
        use :create_params
      end
      post do
        params_except_images = params.except(:image_file)
        if !params[:isbn].present? && params.count < 3
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Minimum two fields are required' },
                                  @current_library, false)
          error!('Minimum two fields are required', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        requested_biblios = @current_library.unique_requested_biblio(params.except(:staff_id))
        unless requested_biblios.blank?
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Demand request already exist for provided information' },
                                  @current_library, false)
          error!('Demand request already exist for provided information', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        requested_biblio = RequestedBiblio.new(declared(params.except(:staff_id), include_missing: false)
                                                 .merge!(library_id: @current_library.id, created_by: Staff.find(params[:staff_id]),updated_by: Staff.find(params[:staff_id])))
        unless params[:author_requested_biblios_attributes].blank?
          params[:author_requested_biblios_attributes].each do |author_requested_biblio|
            author = Author.find_by(id: author_requested_biblio[:author_id])
            unless author.present?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Author not found' },
                                      @current_library, false)
              error!('Author not found', HTTP_CODE[:NOT_FOUND])
            end
          end
        end
        unless params[:biblio_subject_requested_biblios_attributes].blank?
          params[:biblio_subject_requested_biblios_attributes].each do |biblio_subject_requested_biblio|
            biblio_subject = BiblioSubject.find_by(id: biblio_subject_requested_biblio[:biblio_subject_id])
            unless biblio_subject.present?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio subject not found' },
                                      @current_library, false)
              error!('Biblio subject not found', HTTP_CODE[:NOT_FOUND])
            end
          end
        end
        if requested_biblio.save!
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:OK] },
                                  @current_library, true)
          Lms::Entities::RequestedBiblioDetails.represent(requested_biblio, request_source: @request_source)
        end
      end

      desc 'multiple request for biblios'
      params do
        use :multiple_create_params
      end
      post 'multiple' do
        requested_biblios_all = []
        ActiveRecord::Base.transaction do
          params[:biblios].map do |biblio_params|
            if !biblio_params[:isbn].present? && biblio_params.count < 3
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Minimum two fields are required' },
                                      @current_library, false)
              error!('Minimum two fields are required', HTTP_CODE[:NOT_ACCEPTABLE])
            end
            requested_biblios = @current_library.unique_requested_biblio(biblio_params.except(:staff_id))
            unless requested_biblios.blank?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Demand request already exists for provided information' },
                                      @current_library, false)
              error!('Demand request already exists for provided information', HTTP_CODE[:NOT_ACCEPTABLE])
            end
            requested_biblio = RequestedBiblio.new(biblio_params.except(:staff_id)
                                                     .merge!(library_id: @current_library.id,
                                                                        created_by: Staff.find(biblio_params[:staff_id]),
                                                                        updated_by: Staff.find(biblio_params[:staff_id])))

            unless biblio_params[:author_requested_biblios_attributes].blank?
              biblio_params[:author_requested_biblios_attributes].each do |author_requested_biblio|
                author = Author.find_by(id: author_requested_biblio[:author_id])
                unless author.present?
                  LmsLogJob.perform_later(request.headers.merge(params:),
                                          { status_code: HTTP_CODE[:NOT_FOUND], error: 'Author not found' },
                                          @current_library, false)
                  error!('Author not found', HTTP_CODE[:NOT_FOUND])
                end
              end
            end
            unless biblio_params[:biblio_subject_requested_biblios_attributes].blank?
              biblio_params[:biblio_subject_requested_biblios_attributes].each do |biblio_subject_requested_biblio|
                biblio_subject = BiblioSubject.find_by(id: biblio_subject_requested_biblio[:biblio_subject_id])
                unless biblio_subject.present?
                  LmsLogJob.perform_later(request.headers.merge(params:),
                                          { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio subject not found' },
                                          @current_library, false)
                  error!('Biblio subject not found', HTTP_CODE[:NOT_FOUND])
                end
              end
            end
            if requested_biblio.save!
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:OK] },
                                      @current_library, true)
              requested_biblios_all << requested_biblio
            end
          end
        end
        Lms::Entities::RequestedBiblioDetails.represent(requested_biblios_all, request_source: @request_source)
      end
    end
  end
end

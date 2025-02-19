# frozen_string_literal: true

module Lms
  class BiblioClassificationSources < Lms::Base
    helpers Lms::QueryParams::BiblioClassificationSourceParams
    resources :biblio_classification_sources do
      desc 'Search Classification Source'
      params do
        use :pagination, max_per_page: 25
        requires :search_term, type: String
      end

      get 'search' do
        biblio_classification_source = BiblioClassificationSource.not_deleted.where('lower(title) like :search_term',
                                           search_term: "%#{params[:search_term].downcase}%")
        Lms::Entities::BiblioClassificationSourceSearch.represent(biblio_classification_source)
      end
      desc 'Create biblio classification source'
      params do
        use :biblio_classification_source_create_params
      end

      post do
        staff = @current_library.staffs.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                  @current_library,
                                  false)
          error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
        end
        biblio_classification_source = BiblioClassificationSource.not_deleted.find_by(title: params[:title])

        if biblio_classification_source.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:CONFLICT], error: 'Biblio Classification source exists' },
                                  staff, false)
          status HTTP_CODE[:CONFLICT]
          Lms::Entities::BiblioClassificationSources.represent(biblio_classification_source)
        else
          biblio_classification_source = BiblioClassificationSource.new(declared(params, include_missing: false)
                                                                          .except(:staff_id)
                                                                          .merge!(created_by_id: staff.id))
          if biblio_classification_source.save!
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:CREATED] },
                                    staff, true)
            Lms::Entities::BiblioClassificationSources.represent(biblio_classification_source)
          end
        end
      end

      route_param :id do
        desc 'Update biblio classification source'
        params do
          use :biblio_classification_source_update_params
        end

        put do
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    @current_library,
                                    false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end

          biblio_classification_source = BiblioClassificationSource.not_deleted.find_by(id: params[:id])
          unless biblio_classification_source.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND],
                                      error: 'Biblio classification source not found' }, staff, false)
            error!('Biblio classification source not found', HTTP_CODE[:NOT_FOUND])
          end

          biblio_classification_source.update!(declared(params, include_missing: false)
                                                 .except(:staff_id)
                                                 .merge!(updated_by_id: params[:staff_id]))
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  staff, true)
          Lms::Entities::BiblioClassificationSources.represent(biblio_classification_source)
        end

        desc 'Biblio classification source delete'
        params do
          use :biblio_classification_source_delete_params
        end
        delete do
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    @current_library, false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end
          biblio_classification_source = BiblioClassificationSource.not_deleted.find_by(id: params[:id])
          unless biblio_classification_source.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND],
                                      error: 'Biblio classification source not found' },
                                    staff, false)
            error!('Biblio classification source not found', HTTP_CODE[:NOT_FOUND])
          end
          unless biblio_classification_source.biblios.blank?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Has associated biblios' },
                                    staff, false)
            error!('Has associated biblios', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          biblio_classification_source.update!(is_deleted: true, updated_by_id: staff.id, deleted_at: DateTime.now)
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  staff, true)
          Lms::Entities::BiblioClassificationSources.represent(biblio_classification_source)
        end
      end
    end
  end
end

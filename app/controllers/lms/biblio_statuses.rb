# frozen_string_literal: true

module Lms
  class BiblioStatuses < Lms::Base
    resources :biblio_status do
      desc 'Search Biblio Status'
      params do
        use :pagination, max_per_page: 25
        requires :search_term, type: String
      end

      get 'search' do
        biblio_status = BiblioStatus.where('lower(title) like :search_term',
                                           search_term: "%#{params[:search_term].downcase}%")
        Lms::Entities::BiblioStatusSearch.represent(biblio_status)
      end
      desc 'Create biblio status'
      params do
        requires :staff_id, type: Integer
        optional :title, type: String
        requires :status_type, type: String, allow_blank: false, values: %w[lost damage withdrawn discharge weed]
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

        biblio_status = BiblioStatus.find_by(title: params[:title], status_type: params[:status_type])

        if biblio_status.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:CONFLICT], error: 'Biblio status already exists' },
                                  staff, false)
          status HTTP_CODE[:CONFLICT]
          Lms::Entities::BiblioStatus.represent(biblio_status)
        else
          biblio_status = BiblioStatus.new(declared(params, include_missing: false)
                                             .except(:staff_id)
                                             .merge!(created_by_id: staff.id))
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:CREATED] },
                                  staff, true)
          if biblio_status.save!
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
            Lms::Entities::BiblioStatus.represent(biblio_status)
          end
        end
      end

      route_param :id do
        desc 'Update biblio status'
        params do
          requires :staff_id, type: Integer
          optional :title, type: String
          requires :status_type, type: String, allow_blank: false
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
          biblio_status = BiblioStatus.find_by(id: params[:id])
          unless biblio_status.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio status not found' },
                                    staff, false)
            error!('Biblio status not found', HTTP_CODE[:NOT_FOUND])
          end

          biblio_status.update!(declared(params, include_missing: false)
                                   .except(:staff_id)
                                   .merge!(updated_by_id: params[:staff_id]))
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  staff, true)
          Lms::Entities::BiblioStatus.represent(biblio_status)
        end

        desc 'Delete biblio status'

        delete do
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    @current_library,
                                    false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end
          biblio_status = BiblioStatus.find_by(id: params[:id])
          unless biblio_status.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio status not found' },
                                    staff, false)
            error!('Biblio status not found', HTTP_CODE[:NOT_FOUND])
          end
          unless biblio_status.biblio_items.blank?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Has associated biblios' },
                                    staff, false)
            error!('Has associated biblios', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          biblio_status.destroy!
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  staff, true)

        end
      end
    end
  end
end

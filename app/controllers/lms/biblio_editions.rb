# frozen_string_literal: true

module Lms
  class BiblioEditions < Lms::Base
    helpers Lms::QueryParams::BiblioEditionParams
    resources :biblio_editions do
      desc 'Search Biblio Editions'
      params do
        use :pagination, max_per_page: 25
        requires :search_term, type: String
      end
      get 'search' do
        biblio_edition = BiblioEdition.not_deleted.where('lower(title) like :search_term',
                                           search_term: "%#{params[:search_term].downcase}%")
        Lms::Entities::BiblioEditionSearch.represent(biblio_edition)
      end
      desc 'Create biblio edition'
      params do
        use :biblio_edition_create_params
      end

      post do
        staff = @current_library.staffs.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                  @current_library, false)
          error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
        end

        biblio_edition = BiblioEdition.not_deleted.find_by(title: params[:title])

        if biblio_edition.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:CONFLICT], error: 'Biblio edition already exists' },
                                  staff, false)
          status HTTP_CODE[:CONFLICT]
          Lms::Entities::BiblioEditions.represent(biblio_edition)
        else
          biblio_edition = BiblioEdition.new(declared(params, include_missing: false)
                                               .except(:staff_id)
                                               .merge!(created_by_id: staff.id))
          if biblio_edition.save!
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:CREATED] },
                                    staff, true)
            Lms::Entities::BiblioEditions.represent(biblio_edition)
          end
        end
      end

      route_param :id do
        desc 'Update biblio edition'
        params do
          use :biblio_edition_update_params
        end

        put do
          biblio_edition = BiblioEdition.not_deleted.find_by(id: params[:id])
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    @current_library,
                                    false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end
          unless biblio_edition.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio edition not found' },
                                    staff, false)
            error!('Biblio edition not found', HTTP_CODE[:NOT_FOUND])
          end

          biblio_edition.update!(declared(params, include_missing: false)
                                   .except(:staff_id)
                                   .merge!(updated_by_id: params[:staff_id]))
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  staff, true)
          Lms::Entities::BiblioEditions.represent(biblio_edition)
        end

        desc 'Delete biblio edition'

        delete do
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    @current_library,
                                    false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end
          biblio_edition = BiblioEdition.not_deleted.find_by(id: params[:id])
          unless biblio_edition.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio edition not found' },
                                    staff, false)
            error!('Biblio edition not found', HTTP_CODE[:NOT_FOUND])
          end
          unless biblio_edition.biblios.blank?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Has associated biblios' },
                                    staff, false)
            error!('Has associated biblios', HTTP_CODE[:NOT_ACCEPTABLE])
          end

          biblio_edition.update!(is_deleted: true, updated_by_id: staff.id, deleted_at: DateTime.now)
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  staff, true)
          Lms::Entities::BiblioEditions.represent(biblio_edition)
        end
      end
    end
  end
end

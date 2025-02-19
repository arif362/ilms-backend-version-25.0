# frozen_string_literal: true

module Lms
  class BiblioPublications < Lms::Base
    helpers Lms::QueryParams::BiblioPublicationParams
    resources :biblio_publications do

      desc 'Seach biblio publication'
      params do
        use :pagination, max_per_page: 25
        requires :search_term, type: String
      end
      get 'search' do
        publications = BiblioPublication.not_deleted.where('lower(title) like :search_term
                                                             or bn_title like :search_term',
                                                            search_term: "%#{params[:search_term].downcase}%")
        Lms::Entities::BiblioPublicationSearch.represent(publications)
      end

      desc 'Create biblio publication'
      params do
        use :biblio_publication_create_params
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
        biblio_publication = BiblioPublication.not_deleted.find_by(title: params[:title])
        if biblio_publication.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:CONFLICT], error: 'Biblio publication already exists' },
                                  staff, false)
          status HTTP_CODE[:CONFLICT]
          Lms::Entities::BiblioPublications.represent(biblio_publication)
        else
          biblio_publication = BiblioPublication.new(declared(params, include_missing: false)
                                                       .except(:staff_id)
                                                       .merge!(created_by_id: staff.id))
          if biblio_publication.save!
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:CREATED] },
                                    staff, true)
            Lms::Entities::BiblioPublications.represent(biblio_publication)
          end
        end
      end

      route_param :id do
        desc 'Update biblio publication'
        params do
          use :biblio_publication_update_params
        end

        put do
          biblio_publication = BiblioPublication.not_deleted.find_by(id: params[:id])
          error!('Biblio publication not found', HTTP_CODE[:NOT_FOUND]) unless biblio_publication.present?

          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    @current_library,
                                    false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end
          biblio_publication.update!(declared(params, include_missing: false)
                                     .except(:staff_id)
                                     .merge!(updated_by_id: params[:staff_id]))
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  staff, true)
          Lms::Entities::BiblioPublications.represent(biblio_publication)
        end

        desc 'Biblio publication delete'
        params do
          use :biblio_publication_delete_params
        end
        patch do
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    @current_library,
                                    false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end
          biblio_publication = BiblioPublication.not_deleted.find_by(id: params[:id])
          unless biblio_publication.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio publication not found' },
                                    staff, false)
            error!('Biblio publication not found', HTTP_CODE[:NOT_FOUND])
          end
          unless biblio_publication.biblios.blank?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Has associated biblios' },
                                    staff, false)
            error!('Has associated biblios', HTTP_CODE[:NOT_FOUND])
          end
          biblio_publication.update!(is_deleted: true, updated_by_id: staff.id, deleted_at: DateTime.now)
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  staff, true)
          Lms::Entities::BiblioPublications.represent(biblio_publication)
        end
      end
    end
  end
end

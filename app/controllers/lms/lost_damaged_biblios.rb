# frozen_string_literal: true

module Lms
  class LostDamagedBiblios < Lms::Base
    helpers Lms::QueryParams::DamagedBiblioParams
    resources :lost_damaged_biblios do

      desc 'List of a damaged_biblios'
      params do
        use :pagination, per_page: 25
      end
      get do
        lost_damaged_biblios =  @current_library.lost_damaged_biblios
        Lms::Entities::LostDamagedBiblios.represent(paginate(lost_damaged_biblios.order(id: :desc)))
      end

      desc 'Create lost or damaged biblio'
      params do
        use :biblio_damaged_create_params
      end
      post do
        staff = @current_library.staffs.library.find_by(id: params[:staff_id])
        if staff.nil?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'You are not authorized to process this order' },
                                  @current_library, false)
          error!('You are not authorized to process this order', HTTP_CODE[:NOT_FOUND])
        end

        biblio_item = @current_library.biblio_items.find_by(id: params[:biblio_item_id])
        if biblio_item.nil?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'biblio item not found in this library' },
                                  staff, false)
          error!('biblio item not found in this library', HTTP_CODE[:NOT_FOUND])
        end

        if params[:request_type].to_sym == :patron
          if params[:member_id].blank?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:FORBIDDEN], error: 'Member id need for patron damaged initialization' },
                                    staff, false)
            error!('Member id need for patron damaged initialization', HTTP_CODE[:FORBIDDEN])
          end
          if Member.find_by(id: params[:member_id]).nil?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Member not found' },
                                    staff, false)
            error!('Member not found', HTTP_CODE[:NOT_FOUND])
          end
          circulation = Circulation.where(biblio_item_id: params[:biblio_item_id], member_id: params[:member_id]).last
          unless circulation.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST],
                                      error: 'Circulation not found for the member' },
                                    staff, false)
            error!('Circulation not found for the member', HTTP_CODE[:BAD_REQUEST])
          end
          unless circulation&.circulation_status&.borrowed?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST],
                                      error: 'Circulation not in borrowed status' },
                                    staff, false)
            error!('Circulation not in borrowed status', HTTP_CODE[:BAD_REQUEST])
          end
        end

        lost_damaged_biblio = @current_library.lost_damaged_biblios.find_by(biblio_item_id: params[:biblio_item_id])
        if lost_damaged_biblio.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:FORBIDDEN], error: "Already exist #{lost_damaged_biblio.status} request" },
                                  staff, false)
          error!("Already exist #{lost_damaged_biblio.status} request", HTTP_CODE[:FORBIDDEN])
        end

        lost_damaged_biblio = @current_library.lost_damaged_biblios.new(declared(params.except(:staff_id),
                                                                                 include_missing: false))
        lost_damaged_biblio.biblio_id = biblio_item.biblio_id
        lost_damaged_biblio.updated_by = staff
        lost_damaged_biblio.created_by = staff
        lost_damaged_biblio.circulation_id = circulation.id if params[:request_type].to_sym == :patron

        if lost_damaged_biblio.save!
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  staff, true)
          Lms::Entities::LostDamagedBiblios.represent(lost_damaged_biblio)
        end
      end

      route_param :id do
        desc 'details of a damaged_biblio'
        get do
          lost_damaged_biblio = @current_library.lost_damaged_biblios.find_by(id: params[:id])
          unless lost_damaged_biblio.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio Not Found' },
                                    @current_library, false)
            error!('Biblio Not Found', HTTP_CODE[:NOT_FOUND])
          end

          Lms::Entities::LostDamagedBiblios.represent(lost_damaged_biblio)
        end
      end
    end
  end
end
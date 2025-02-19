# frozen_string_literal: true

module Lms
  class ExtendRequests < Lms::Base
    resources :extend_requests do
      desc 'Approve or reject extend request'

      params do
        requires :staff_id, type: Integer
        requires :status, type: String, values: %w[approved rejected], allow_blank: false
        requires :accession_no, type: String, allow_blank: false
        requires :member_id, type: Integer, allow_blank: false
      end

      put 'status_update' do
        staff = @current_library.staffs.library.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                  @current_library, false)
          error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
        end
        biblio_item = @current_library.biblio_items.find_by(accession_no: params[:accession_no])
        error!("#{params[:accession_no]} accession no not found", HTTP_CODE[:NOT_FOUND]) unless biblio_item.present?

        circulation = @current_library.circulations.find_by(biblio_item_id: biblio_item.id,
                                                            member_id: params[:member_id],
                                                            circulation_status_id: CirculationStatus.get_status('borrowed').id)
        extend_request = @current_library.extend_requests.find_by(circulation_id: circulation.id)
        unless extend_request.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND],
                                    error: 'Extend request not found for this library' },
                                  staff, false)
          error!('Extend request not found for this library', HTTP_CODE[:NOT_FOUND])
        end
        unless extend_request.pending?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST],
                                    error: 'Extend request not in pending status' },
                                  staff, false)
          error!('Extend request not in pending status', HTTP_CODE[:BAD_REQUEST])
        end
        unless circulation.circulation_status.borrowed?
          error!("Circulation with id: #{circulation.id} not in borrowed status", HTTP_CODE[:NOT_ACCEPTABLE])
        end
        if circulation.return_order&.present?
          error!("Return already initiated for circulation with id: #{circulation.id}", HTTP_CODE[:NOT_ACCEPTABLE])
        end
        extend_request.update!(updated_by: staff, status: params[:status])
        if params[:status] == 'approved'
          circulation.update_columns(updated_by_id: staff.id,
                                     updated_by_type: 'Staff',
                                     return_at: circulation.return_at.advance(days: ENV['BORROW_EXTEND_DAYS'].to_i))
        end
        Lms::Entities::ExtendRequests.represent(extend_request)
      end
    end
  end
end

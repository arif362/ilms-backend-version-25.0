# frozen_string_literal: true

module Lms
  class BookTransferOrders < Lms::Base
    resources :book_transfer_orders do

      route_param :id do
        desc 'Status Update of BTO'
        params do
          requires :status, type: String, values: %w[accepted rejected], allow_blank: false
          requires :staff_id, type: Integer, allow_blank: false
          optional :sender_library_id, type: Integer, allow_blank: false
          optional :start_date, type: DateTime, allow_blank: false
          optional :end_date, type: DateTime, allow_blank: false
          optional :note, type: String, allow_blank: false
        end
        patch :accept_reject do
          staff = @current_library.staffs.library.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    @current_library, false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end

          book_transfer_order = @current_library.book_transfer_orders.find_by(id: params[:id])
          unless book_transfer_order.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Book transfer order request not found' },
                                    staff, false)
            error!('Book transfer order request not found', HTTP_CODE[:NOT_FOUND])
          end

          if params[:status] == 'accepted'
            unless params[:sender_library_id].present?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Sender library must be present' },
                                      staff, false)
              error!('Sender library must be present', HTTP_CODE[:NOT_ACCEPTABLE])
            end
            sender_library = Library.find_by(id: params[:sender_library_id])
            unless sender_library.present?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Sender library not found' },
                                      staff, false)
              error!('Sender library not found', HTTP_CODE[:NOT_FOUND])
            end
            unless params[:start_date].present? || params[:end_date].present?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:NOT_FOUND],
                                        error: 'Start date and end date are required for accepted status' },
                                      staff, false)
              error!('Start date and end date are required for accepted status')
            end
          else
            unless params[:note].present?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Note is required for rejecting' },
                                      staff, false)
              error!('Note is required for rejecting', HTTP_CODE[:NOT_ACCEPTABLE])
            end
          end

          unless book_transfer_order.pending?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Book transfer order request is not at pending state' },
                                    staff, false)
            error!('Book transfer order request is not at pending state', HTTP_CODE[:NOT_ACCEPTABLE])
          end
          book_transfer_order.sender_library_id = params[:sender_library_id]
          book_transfer_order.start_date = params[:start_date]
          book_transfer_order.end_date = params[:end_date]
          book_transfer_order.status = params[:status]
          book_transfer_order.updated_by = staff
          book_transfer_order.save!

          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  staff, true)
          Lms::Entities::LibraryTransferOrders.represent(book_transfer_order.reload&.library_transfer_orders&.last)
        end
      end
    end
  end
end

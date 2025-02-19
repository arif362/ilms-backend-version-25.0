# frozen_string_literal: true

module Lms
  class IntLibExtensions < Lms::Base
    helpers Lms::QueryParams::IntLibExtensionParams

    resources :int_lib_extensions do
      desc 'inter library circulation extension request'

      params do
        use :int_lib_extension_create_params
      end

      post do
        staff = @current_library.staffs.library.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                  @current_library, false)
          error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
        end
        book_transfer_order = @current_library.book_transfer_orders.find_by(id: params[:book_transfer_order_id])
        unless book_transfer_order.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Book transfer order not found' },
                                  staff, false)
          error!('Book transfer order not found', HTTP_CODE[:NOT_FOUND])
        end

        library_transfer_order = book_transfer_order.library_transfer_orders.last
        unless library_transfer_order.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Library transfer order not found' },
                                  staff, false)
          error!('Library transfer order not found', HTTP_CODE[:NOT_FOUND])
        end
        unless library_transfer_order.transfer_order_status.delivered?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST],
                                    error: 'Library transfer order not in delivered status' },
                                  staff, false)
          error!('Library transfer order not in delivered status', HTTP_CODE[:BAD_REQUEST])
        end

        prev_int_lib_extensions = IntLibExtension.where(library_transfer_order_id: library_transfer_order.id)
        if prev_int_lib_extensions.present?
          has_pending_or_approved = prev_int_lib_extensions.any? do |int_lib_extension|
            int_lib_extension.pending? || int_lib_extension.accepted?
          end
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST],
                                    error: 'Approved or pending request exist' },
                                  staff, false)
          error!('Approved or pending request exist', HTTP_CODE[:BAD_REQUEST]) if has_pending_or_approved.present?
        end
        int_lib_extension = library_transfer_order.int_lib_extensions.new(sender_library: library_transfer_order.sender_library,
                                                                          receiver_library: library_transfer_order.receiver_library,
                                                                          extend_end_date: params[:extend_end_date],
                                                                          created_by: staff,
                                                                          updated_by: staff)
        if int_lib_extension.save!
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:CREATED] },
                                  staff, true)
          Lms::Entities::IntLibExtension.represent(int_lib_extension)
        end
      end

      desc 'inter library circulation extension request status update'

      params do
        use :int_lib_extension_update_params
      end

      put 'status_update' do
        staff = @current_library.staffs.library.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                  @current_library, false)
          error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
        end
        book_transfer_order = BookTransferOrder.find_by(id: params[:book_transfer_order_id])
        unless book_transfer_order.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Book transfer order not found' },
                                  @current_library, false)
          error!('Book transfer order not found', HTTP_CODE[:NOT_FOUND])
        end
        library_transfer_order = book_transfer_order.library_transfer_orders
                                                    .where(sender_library_id: @current_library.id,
                                                           order_type: 'forword')
                                                    .last
        unless library_transfer_order.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Library transfer order not found' },
                                  staff, false)
          error!('Library transfer order not found', HTTP_CODE[:NOT_FOUND])
        end

        unless library_transfer_order.transfer_order_status.delivered?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST],
                                    error: 'Library transfer order not in delivered status' },
                                  staff, false)
          error!('Library transfer order not in delivered status', HTTP_CODE[:BAD_REQUEST])
        end

        int_lib_extension = library_transfer_order.int_lib_extensions.find_by(sender_library: @current_library,
                                                                              receiver_library: library_transfer_order.receiver_library,)

        unless int_lib_extension.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND],
                                    error: 'Inter library extension request not found' },
                                  staff, false)
          error!('Inter library extension request not found', HTTP_CODE[:NOT_FOUND])
        end
        unless int_lib_extension.pending?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:BAD_REQUEST],
                                    error: 'Inter library extension request not in pending status' },
                                  staff, false)
          error!('Inter library extension request not in pending status', HTTP_CODE[:BAD_REQUEST])
        end
        int_lib_extension.update!(updated_by: staff, status: params[:status])
        LmsLogJob.perform_later(request.headers.merge(params:),
                                { status_code: HTTP_CODE[:OK] },
                                staff, true)
        Lms::Entities::IntLibExtension.represent(int_lib_extension)
      end
    end
  end
end

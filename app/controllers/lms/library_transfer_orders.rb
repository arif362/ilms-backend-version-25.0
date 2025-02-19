# frozen_string_literal: true

module Lms
  class LibraryTransferOrders < Lms::Base
    resources :library_transfer_orders do

      # NOTE: params[:id] is comming as ref of book transfer order id
      route_param :id do
        desc 'Accept/Reject/in_transit LTO by sender library'
        params do
          requires :status, type: String, values: %w[accepted rejected in_transit], allow_blank: false
          requires :staff_id, type: Integer, allow_blank: false
          optional :reference_no, type: String, allow_blank: false
          optional :lto_line_items, type: Array[JSON] do
            requires :biblio_id, type: Integer, allow_blank: false
            requires :barcode, type: String, allow_blank: false
          end
        end
        patch do
          staff = @current_library.staffs.library.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not found' },
                                    @current_library, false)
            error!('Staff not found', HTTP_CODE[:NOT_FOUND])
          end

          book_transfer_order = BookTransferOrder.find_by(id: params[:id]) # NOTE: params[:id] is comming as ref of book transfer order id
          unless book_transfer_order.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Reference book transfer request not found in your library' },
                                    staff, false)
            error!('Reference book transfer request not found in your library', HTTP_CODE[:NOT_FOUND])
          end

          library_transfer_order = LibraryTransferOrder.forword.find_by(id: book_transfer_order.library_transfer_orders&.last&.id,
                                                                        sender_library: @current_library)

          unless library_transfer_order.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Library transfer order request not found in your library' },
                                    staff, false)
            error!('Library transfer order request not found in your library', HTTP_CODE[:NOT_FOUND])
          end

          transfer_order_status = TransferOrderStatus.get_status(params[:status].to_sym)
          unless transfer_order_status.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Transfer order status not found' },
                                    staff, false)
            error!('Transfer order status not found', HTTP_CODE[:NOT_FOUND])
          end

          if transfer_order_status.accepted? && !library_transfer_order.transfer_order_status.pending?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST], error: 'This request is not in pending list' },
                                    staff, false)
            error!('This request is not in pending list', HTTP_CODE[:BAD_REQUEST])
          end

          if transfer_order_status.rejected? && !library_transfer_order.transfer_order_status.pending?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST], error: 'This request is not found in pending list' },
                                    staff, false)
            error!('This request is not found in pending list', HTTP_CODE[:BAD_REQUEST])
          end

          if (transfer_order_status.in_transit? || transfer_order_status.rejected?) && !params[:reference_no].present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Reference no is required' },
                                    staff, false)
            error!('Reference no is required', HTTP_CODE[:BAD_REQUEST])
          end

          if transfer_order_status.in_transit? && !library_transfer_order.transfer_order_status.accepted?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST], error: 'This request is not found in accepted list' },
                                    staff, false)
            error!('This request is not found in accepted list ', HTTP_CODE[:BAD_REQUEST])
          end

          if transfer_order_status.accepted?
            unless params[:lto_line_items].present?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:BAD_REQUEST], error: 'LTO line items required' },
                                      staff, false)
              error!('LTO line items required', HTTP_CODE[:BAD_REQUEST])
            end

            ActiveRecord::Base.transaction do
              params[:lto_line_items].each do |line_item_params|
                line_item = library_transfer_order.lto_line_items.find_by(biblio_id: line_item_params['biblio_id'])
                if line_item.nil?
                  LmsLogJob.perform_later(request.headers.merge(params:),
                                          { status_code: HTTP_CODE[:NOT_FOUND], error: 'Requested Item Not Found' },
                                          staff, false)
                  error!('Requested Item Not Found', HTTP_CODE[:NOT_FOUND])
                end

                biblio_item = line_item.biblio.biblio_items.find_by(barcode: line_item_params[:barcode])
                if biblio_item.nil?
                  LmsLogJob.perform_later(request.headers.merge(params:),
                                          { status_code: HTTP_CODE[:NOT_FOUND], error: 'Biblio Item Not Found By Barcode' },
                                          staff, false)
                  error!('Biblio Item Not Found By Barcode', HTTP_CODE[:NOT_FOUND])
                end

                if biblio_item.not_for_loan
                  LmsLogJob.perform_later(request.headers.merge(params:),
                                          { status_code: HTTP_CODE[:UNPROCESSABLE_ENTITY], error: 'This Biblio Item is not for borrow' },
                                          staff, false)
                  error!('This Biblio Item is not for borrow', HTTP_CODE[:UNPROCESSABLE_ENTITY])
                end
                circulation = Circulation.where(biblio_item_id: biblio_item.id)&.last

                if circulation&.circulation_status&.borrowed?
                  LmsLogJob.perform_later(request.headers.merge(params:),
                                          { status_code: HTTP_CODE[:NOT_FOUND], error: "#{biblio_item.biblio.title&.titleize} not available now" },
                                          staff, false)
                  error!("#{biblio_item.biblio.title&.titleize} not available now", HTTP_CODE[:NOT_FOUND])
                end

                next unless line_item.update!(biblio_item_id: biblio_item.id, price: biblio_item.price)

                LmsLogJob.perform_later(request.headers.merge(params:),
                                        { status_code: HTTP_CODE[:OK] },
                                        staff, true)
              end

              unless library_transfer_order.line_items_filled_up?
                LmsLogJob.perform_later(request.headers.merge(params:),
                                        { status_code: HTTP_CODE[:UNPROCESSABLE_ENTITY], error: 'Biblio item not assigned to all line items' },
                                        staff, false)
                error!('Biblio item not assigned to all line items', HTTP_CODE[:UNPROCESSABLE_ENTITY])
              end
            end
          end

          if library_transfer_order.update!(transfer_order_status:,
                                            updated_by: staff,
                                            reference_no: params[:reference_no])
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
          end
          if @current_library == library_transfer_order.sender_library
            Lms::InterLibraryTransferManage::LtoStatusUpdateJob.perform_later(library_transfer_order,
                                                                              params[:status],
                                                                              'receiver',
                                                                              @current_library)
            # library_transfer_order.update_columns(return_at: DateTime.now.advance(days: ENV['INTER_LIB_BORROW_DAYS'].to_i))
          end

          Lms::Entities::LibraryTransferOrders.represent(library_transfer_order)
        end

        desc 'Delivery inter library transfer order'
        params do
          requires :staff_id, type: Integer, allow_blank: false
        end
        patch :delivered_to_library do
          staff = @current_library.staffs.library.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not found' },
                                    @current_library, false)
            error!('Staff not found', HTTP_CODE[:NOT_FOUND])
          end

          book_transfer_order = BookTransferOrder.find_by(id: params[:id]) # NOTE: params[:id] is comming as ref of book transfer order id
          unless book_transfer_order.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Reference book transfer request not found in your library' },
                                    staff, false)
            error!('Reference book transfer request not found in your library', HTTP_CODE[:NOT_FOUND])
          end

          library_transfer_order = LibraryTransferOrder.forword.find_by(id: book_transfer_order.library_transfer_orders&.last&.id,
                                                                        receiver_library: @current_library)
          unless library_transfer_order.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Library transfer order request not found in your library' },
                                    staff, false)
            error!('Library transfer order request not found in your library', HTTP_CODE[:NOT_FOUND])
          end

          transfer_order_status = TransferOrderStatus.get_status(TransferOrderStatus.status_keys[:delivered])
          unless transfer_order_status.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Transfer order delivered status not found' },
                                    staff, false)
            error!('Transfer order delivered status not found', HTTP_CODE[:NOT_FOUND])
          end

          unless library_transfer_order.transfer_order_status.in_transit?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'This request is not found in in-transit' },
                                    staff, false)
            error!('This request is not found in in-transit', HTTP_CODE[:NOT_ACCEPTABLE])
          end

          if library_transfer_order.update!(transfer_order_status:, updated_by: staff)
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
            Lms::InterLibraryTransferManage::LtoStatusUpdateJob.perform_later(library_transfer_order,
                                                                              transfer_order_status.status_key,
                                                                              'sender',
                                                                              @current_library)
          end
          library_transfer_order.add_as_other_library_biblio
          Lms::Entities::LibraryTransferOrders.represent(library_transfer_order)
        end

        desc 'Library Transfer Order Extend'
        params do
          requires :staff_id, type: Integer, allow_blank: false
        end
        patch 'extend'do

          staff = @current_library.staffs.library.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not found' },
                                    @current_library, false)
            error!('Staff not found', HTTP_CODE[:NOT_FOUND])
          end

          library_transfer_order = LibraryTransferOrder.return.find_by(id: params[:id],
                                                                       receiver_library: @current_library)

          unless library_transfer_order.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Library transfer order request not found in your library' },
                                    staff, false)
            error!('Library transfer order request not found in your library', HTTP_CODE[:NOT_FOUND])
          end

          if library_transfer_order.update_columns(end_date: library_transfer_order.end_date + ENV['INTER_LIB_BORROW_DAYS_EXTEND'].to_i.days)
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
          end

          Lms::Entities::LibraryTransferOrders.represent(library_transfer_order)
        end

      end

      resources :return do
        desc 'LTO return by receiver library'
        params do
          requires :staff_id, type: Integer, allow_blank: false
          requires :to_library_id, type: Integer, allow_blank: false
          requires :lto_line_items, type: Array[JSON] do
            requires :barcode, type: String, allow_blank: false
          end
        end

        post do
          staff = @current_library.staffs.library.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not found' },
                                    @current_library, false)
            error!('Staff not found', HTTP_CODE[:NOT_FOUND])
          end

          to_library = Library.find_by(id: params[:to_library_id])
          unless to_library.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Receiver/to library not found' },
                                    staff, false)
            error!('Receiver/to library not found', HTTP_CODE[:NOT_FOUND])
          end

          library_transfer_order_return = LibraryTransferOrder.return.create!(receiver_library: to_library,
                                                                              sender_library: @current_library,
                                                                              transfer_order_status: TransferOrderStatus.get_status(:initiated))
          if library_transfer_order_return.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
          end

          ActiveRecord::Base.transaction do
            params[:lto_line_items].each do |line_item_params|
              biblio_id = BiblioItem.find_by(barcode: line_item_params[:barcode])&.biblio_id

              unless biblio_id.present?
                LmsLogJob.perform_later(request.headers.merge(params:),
                                        { status_code: HTTP_CODE[:NOT_FOUND], error: "Item of barcode: #{line_item_params['barcode']} not found" },
                                        staff, false)
                error!("Item of barcode: #{line_item_params['barcode']} not found",
                       HTTP_CODE[:NOT_FOUND])
              end

              line_item = LtoLineItem.find_by(biblio_id: biblio_id) || ReturnItem.find_by(biblio_id: biblio_id)

              unless line_item.present?
                LmsLogJob.perform_later(request.headers.merge(params:),
                                        { status_code: HTTP_CODE[:NOT_FOUND], error: "Item of barcode: #{line_item_params['barcode']} not found in int-library circulation list" },
                                        staff, false)
                error!("Item of barcode: #{line_item_params['barcode']} not found in int-library circulation list",
                       HTTP_CODE[:NOT_FOUND])
              end

              if line_item.is_a?(LtoLineItem) && line_item.library_transfer_order&.receiver_library != @current_library
                LmsLogJob.perform_later(request.headers.merge(params:),
                                        { status_code: HTTP_CODE[:NOT_FOUND], error: "Item of barcode: #{line_item_params['barcode']} is not authorized to return by your library" },
                                        staff, false)
                error!("Item of barcode: #{line_item_params['barcode']} is not authorized to return by your library",
                       HTTP_CODE[:NOT_FOUND])
              end

              if line_item.is_a?(ReturnItem) && line_item.return_order&.library != @current_library
                LmsLogJob.perform_later(request.headers.merge(params:),
                                        { status_code: HTTP_CODE[:NOT_FOUND], error: "Item of barcode: #{line_item_params['barcode']} is not authorized to return by your library" },
                                        staff, false)
                error!("Item of barcode: #{line_item_params['barcode']} is not authorized to return by your library",
                       HTTP_CODE[:NOT_FOUND])
              end

              biblio_item = line_item.biblio.biblio_items.find_by(barcode: line_item_params[:barcode])
              if biblio_item.nil?
                LmsLogJob.perform_later(request.headers.merge(params:),
                                        { status_code: HTTP_CODE[:NOT_FOUND], error: "Biblio Item Not Found By Barcode: #{line_item_params['barcode']}" },
                                        staff, false)
                error!("Biblio Item Not Found By Barcode: #{line_item_params['barcode']}", HTTP_CODE[:NOT_FOUND])
              end

              circulation = Circulation.where(biblio_item_id: biblio_item.id)&.last

              if circulation&.circulation_status&.borrowed?
                LmsLogJob.perform_later(request.headers.merge(params:),
                                        { status_code: HTTP_CODE[:NOT_FOUND], error: "#{biblio_item.biblio.title&.titleize} not available now" },
                                        staff, false)
                error!("#{biblio_item.biblio.title&.titleize} not available now", HTTP_CODE[:NOT_FOUND])
              end

              library_transfer_order_return.reload.lto_line_items.create!(biblio_item_id: line_item.biblio_item_id,
                                                                                price: line_item.price, biblio_id: line_item.biblio_id )
            end

            unless library_transfer_order_return.line_items_filled_up?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:UNPROCESSABLE_ENTITY], error: 'Biblio item not assigned to all line items' },
                                      staff, false)
              error!('Biblio item not assigned to all line items', HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
          end

          Lms::Entities::LibraryTransferOrders.represent(library_transfer_order_return)
        end

        route_param :id do
          desc 'LTO return status update'
          params do
            requires :status, type: String, values: %w[in_transit], allow_blank: false
            requires :staff_id, type: Integer, allow_blank: false
            optional :reference_no, type: String, allow_blank: false
          end
          patch do

            staff = @current_library.staffs.library.find_by(id: params[:staff_id])
            unless staff.present?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not found' },
                                      @current_library, false)
              error!('Staff not found', HTTP_CODE[:NOT_FOUND])
            end

            library_transfer_order = LibraryTransferOrder.return.find_by(id: params[:id],
                                                                         sender_library: @current_library)

            unless library_transfer_order.present?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Library transfer order request not found in your library' },
                                      staff, false)
              error!('Library transfer order request not found in your library', HTTP_CODE[:NOT_FOUND])
            end

            transfer_order_status = TransferOrderStatus.get_status(params[:status].to_sym)
            unless transfer_order_status.present?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Transfer order status not found' },
                                      staff, false)
              error!('Transfer order status not found', HTTP_CODE[:NOT_FOUND])
            end

            if transfer_order_status.delivered? && !library_transfer_order.transfer_order_status.in_transit?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:BAD_REQUEST], error: 'This request is not in in-transit list' },
                                      staff, false)
              error!('This request is not in in in-transit list', HTTP_CODE[:BAD_REQUEST])
            end


            if transfer_order_status.in_transit? && !params[:reference_no].present?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:BAD_REQUEST], error: 'in_transit reference-no is required' },
                                      staff, false)
              error!('in_transit reference-no is required', HTTP_CODE[:BAD_REQUEST])
            end


            if library_transfer_order.update!(transfer_order_status:, updated_by: staff, reference_no: params[:reference_no])
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:OK] },
                                      staff, true)
            end
            Lms::InterLibraryTransferManage::LtoReturnStatusUpdateJob.perform_later(library_transfer_order,
                                                                                    transfer_order_status.status_key,
                                                                                    'receiver',
                                                                                    @current_library)
            Lms::Entities::LibraryTransferOrders.represent(library_transfer_order)
          end


          desc 'LTO return delivery status update'
          params do
            requires :staff_id, type: Integer, allow_blank: false
          end

          patch 'delivered' do
            staff = @current_library.staffs.library.find_by(id: params[:staff_id])
            unless staff.present?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff not found' },
                                      @current_library, false)
              error!('Staff not found', HTTP_CODE[:NOT_FOUND])
            end

            library_transfer_order = LibraryTransferOrder.return.find_by(id: params[:id],
                                                                         receiver_library: @current_library)

            unless library_transfer_order.present?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Library transfer order request not found in your library' },
                                      staff, false)
              error!('Library transfer order request not found in your library', HTTP_CODE[:NOT_FOUND])
            end

            transfer_order_status = TransferOrderStatus.get_status('delivered')
            unless transfer_order_status.present?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Transfer order status not found' },
                                      staff, false)
              error!('Transfer order status not found', HTTP_CODE[:NOT_FOUND])
            end

            if transfer_order_status.delivered? && !library_transfer_order.transfer_order_status.in_transit?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:BAD_REQUEST], error: 'This request is not in in-transit list' },
                                      staff, false)
              error!('This request is not in in-transit list yet', HTTP_CODE[:BAD_REQUEST])
            end


            if library_transfer_order.update!(transfer_order_status:, updated_by: staff)
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:OK] },
                                      staff, true)
            end
            Lms::InterLibraryTransferManage::LtoReturnStatusUpdateJob.perform_later(library_transfer_order,
                                                                                    transfer_order_status.status_key,
                                                                                    'sender',
                                                                                    @current_library)
            Lms::Entities::LibraryTransferOrders.represent(library_transfer_order)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Lms
  class Orders < Lms::Base
    resources :orders do
      desc 'Order list'
      params do
        use :pagination, per_page: 25
      end
      get do
        orders = @current_library.orders.order(id: :desc)
        Lms::Entities::Orders.represent(paginate(orders))
      end

      route_param :id do
        desc 'Order Details'
        get do
          order = @current_library.orders.find_by(id: params[:id])
          if order.nil?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Order Not Found' },
                                    @current_library, false)
            error!('Order Not Found', HTTP_CODE[:NOT_FOUND])
          end
          Lms::Entities::OrderDetails.represent(order)
        end

        desc 'Confirm Order'
        params do
          requires :line_items, type: Array do
            requires :biblio_id, type: Integer, allow_blank: false
            requires :barcode, type: String, allow_blank: false
          end
          requires :staff_id, type: Integer, allow_blank: false
        end
        post :confirm do
          staff = @current_library.staffs.library.find_by(id: params[:staff_id])
          if staff.nil?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'You are not authorized to process this order' },
                                    @current_library, false)
            error!('You are not authorized to process this order', HTTP_CODE[:NOT_FOUND])
          end

          order = @current_library.orders.find_by(id: params[:id])
          if order.nil?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Order Not Found' },
                                    staff, false)
            error!('Order Not Found', HTTP_CODE[:NOT_FOUND])
          end
          unless order.order_status.order_placed?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:UNPROCESSABLE_ENTITY], error: 'Order not in confirmable state' },
                                    staff, false)
            error!('Order not in confirmable state', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          if order.pickup? && (@current_library.id != order.library_id)
            error!('This library is not authorized to delivery this order', HTTP_CODE[:FORBIDDEN])
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:FORBIDDEN], error: 'This library is not authorized to delivery this order' },
                                    staff, false)
          end
          unless order.user.membership?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:UNPROCESSABLE_ENTITY], error: 'Membership required for confirmation this order' },
                                    staff, false)
            error!('Membership required for confirmation this order', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          ActiveRecord::Base.transaction do
            params[:line_items].each do |line_item_params|
              line_item = order.line_items.find_by(biblio_id: line_item_params['biblio_id'])
              if line_item.nil?
                LmsLogJob.perform_later(request.headers.merge(params:),
                                        { status_code: HTTP_CODE[:NOT_FOUND], error: 'Order Item Not Found' },
                                        staff, false)
                error!('Order Item Not Found', HTTP_CODE[:NOT_FOUND])
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

              if line_item.update!(biblio_item_id: biblio_item.id, price: biblio_item.price)
                LmsLogJob.perform_later(request.headers.merge(params:),
                                        { status_code: HTTP_CODE[:CREATED] },
                                        staff, true)
              end
            end

            unless order.line_items_filled_up?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:UNPROCESSABLE_ENTITY], error: 'Biblio item not assigned to all line items' },
                                      staff, false)
              error!('Biblio item not assigned to all line items', HTTP_CODE[:UNPROCESSABLE_ENTITY])
            end
            status = OrderStatus.get_status(:order_confirmed)

            if order.update!(order_status_id: status.id, updated_by: staff)
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CODE[:OK] },
                                      staff, true)
            end
          end

          Lms::Entities::OrderDetails.represent(order)
        end

        desc 'Status Update Order'
        params do
          requires :status_key, type: String, values: OrderStatus.status_keys.keys - %w[order_placed order_confirmed]
          requires :staff_id, type: Integer
        end
        put :update_status do
          staff = @current_library.staffs.library.find_by(id: params[:staff_id])
          if staff.nil?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'You are not authorized to process this order' },
                                    @current_library, false)
            error!('You are not authorized to process this order', HTTP_CODE[:NOT_FOUND])
          end

          order = @current_library.orders.find_by(id: params[:id]) || Order.find_by(id: params[:id],
                                                                                    pick_up_library_id: @current_library.id)
          if order.nil?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Order Not Found' },
                                    staff, false)
            error!('Order Not Found', HTTP_CODE[:NOT_FOUND])
          end
          unless order.user.membership?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:UNPROCESSABLE_ENTITY], error: 'Membership is invalid' },
                                    staff, false)
            error!('Membership is invalid', HTTP_CODE[:UNPROCESSABLE_ENTITY])
          end

          status = OrderStatus.get_status(params[:status_key])
          if status.nil?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Order Status Not Found' },
                                    staff, false)
            error!('Order Status Not Found', HTTP_CODE[:NOT_FOUND])
          end

          if (status.cancelled? || status.rejected?) && !order.order_status.order_placed?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST], error: "Order can only be #{params[:status_key]} when order status is order placed" },
                                    staff, false)
            error!("Order can only be #{params[:status_key]} when order status is order placed",
                   HTTP_CODE[:BAD_REQUEST])
          end

          if %w[rejected cancelled].exclude?(params[:status_key]) && !order.paid?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:PAYMENT_REQUIRED], error: 'Payment not done yet' },
                                    staff, false)
            error!('Payment not done yet', HTTP_CODE[:PAYMENT_REQUIRED])
          end

          if status.ready_for_pickup? && !order.order_status.order_confirmed?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Order not ready for pickup able state' },
                                    staff, false)
            error!('Order not ready for pickup able state', HTTP_CODE[:BAD_REQUEST])
          end

          if status.delivered? && !(order.order_status.collected_by_3pl? || order.pickup?)
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:BAD_REQUEST], error: 'Order not deliverable state' },
                                    staff, false)
            error!('Order not deliverable state', HTTP_CODE[:BAD_REQUEST])
          end
          if status.delivered? && order.pickup? && (@current_library.id != order.pick_up_library_id)
            error!('This library is not authorized to delivery this order', HTTP_CODE[:FORBIDDEN])
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:FORBIDDEN], error: 'This library is not authorized to delivery this order' },
                                    staff, false)
          end

          if order.update!(order_status_id: status.id, updated_by: staff)
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
            Lms::Entities::OrderDetails.represent(order)
          end
        end
      end
    end
  end
end

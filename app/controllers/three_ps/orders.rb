# frozen_string_literal: true

module ThreePs
  class Orders < ThreePs::Base

    resources :orders do
      desc 'order status update'

      params do
        requires :tracking_id, type: String
        requires :message_en, type: String
        optional :message_bn, type: String
        requires :status, type: String, values: %w[ready-for-delivery delivery-in-progress delivered agent-hold]
        requires :token, type: String
      end

      route_setting :authentication, optional: true
      post 'update_status' do
        auth_key = AuthorizationKey.find_by(token: params[:token])
        if auth_key.present? && auth_key.authable.is_active?
          current_3ps_user = auth_key.authable
          unless current_3ps_user.is_a?(ThirdPartyUser) && current_3ps_user.delivery_support?
            error!('Unauthorized', HTTP_CODE[:UNAUTHORIZED])
          end
        else
          error!('Unauthorized', HTTP_CODE[:UNAUTHORIZED])
        end

        order = Order.find_by(tracking_id: params[:tracking_id])
        error!("Order not found for tracking id #{params[:tracking_id]}", HTTP_CODE[:NOT_FOUND]) unless order.present?

        error!('Payment not done yet', HTTP_CODE[:PAYMENT_REQUIRED]) unless order.paid?
        error!('Membership is invalid', HTTP_CODE[:UNPROCESSABLE_ENTITY]) unless order.user.membership?


        status_key = case params[:status]
                     when 'delivered'
                       'delivered'
                     when 'delivery-in-progress'
                       'collected_by_3pl'
                     when 'agent-hold'
                       'collected_by_3pl'
                     else
                       'no status'
                     end

        status = OrderStatus.get_status(status_key)

        error!('Order Status Not Found', HTTP_CODE[:NOT_FOUND]) unless status.present?

        if status.collected_by_3pl? && !order.order_status.ready_for_pickup?
          error!('Order not collectable state', HTTP_CODE[:BAD_REQUEST])
        end

        if status.delivered? && !order.order_status.collected_by_3pl?
          error!('Order not deliverable state', HTTP_CODE[:BAD_REQUEST])
        end

        order.update!(order_status: OrderStatus.get_status(params[:status_key].to_sym),
                      update_by_id: current_3ps_user.id, update_by_type: 'ThirdPartyUser')
        ThreePs::Entities::Orders.represent(order)
      end

    end
  end
end

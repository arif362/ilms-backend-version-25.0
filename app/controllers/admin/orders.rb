# frozen_string_literal: true

module Admin
  class Orders < Admin::Base
    include Admin::Helpers::AuthorizationHelpers

    resources :orders do
      desc 'Order list'
      params do
        use :pagination, per_page: 25
        optional :status_id, type: Integer, allow_blank: false
        optional :delivery_type, type: String, values: Order.delivery_types.keys, allow_blank: false
        optional :recipient_phone, type: String, allow_blank: false
        optional :library_id, type: Integer, allow_blank: false
      end
      get do
        orders = Order.includes(:user, :library)
        authorize orders, :read?
        orders = orders.where(order_status_id: params[:status_id]) if params[:status_id].present?
        orders = orders.where(delivery_type: params[:delivery_type]) if params[:delivery_type].present?
        orders = orders.where(recipient_phone: params[:recipient_phone]) if params[:recipient_phone].present?
        orders = orders.where(library_id: params[:library_id]) if params[:library_id].present?
        orders = orders.order(id: :desc)
        Admin::Entities::Orders.represent(paginate(orders))
      end

      desc 'Order status list for dropdown'
      get :statuses do
        OrderStatus.all.pluck(:admin_status, :id)
      end

      route_param :id do
        desc 'Order details'

        get do
          order = Order.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) if order.nil?
          authorize order, :read?
          Admin::Entities::OrderDetails.represent(order)
        end
      end
    end
  end
end
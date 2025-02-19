# frozen_string_literal: true

module Admin
  class OrderStatuses < Admin::Base
    resources :order_statuses do

      desc 'order_statuses dropdown List'

      get 'dropdown' do
        order_statuses = OrderStatus.all.order(id: :asc)
        Admin::Entities::OrderStatuses.represent(order_statuses)
      end
    end
  end
end

# frozen_string_literal: true

module ThreePs
  module Entities
    class ReturnOrders < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :id
      expose :created_at
      expose :return_status, using: ThreePs::Entities::OrderStatus
      expose :order_items

      def order_items
        ThreePs::Entities::OrderItems.represent(object.return_items)
      end
    end
  end
end

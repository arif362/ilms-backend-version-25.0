# frozen_string_literal: true

module Admin
  module Entities
    class OrderStatusChanges < Grape::Entity
      expose :status
      expose :created_at

      def status
        object.order_status&.admin_status
      end
    end
  end
end

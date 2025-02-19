# frozen_string_literal: true

module Lms
  module Entities
    class OrderStatusChanges < Grape::Entity
      expose :status
      expose :created_at

      def status
        object.order_status&.lms_status
      end
    end
  end
end

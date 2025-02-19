# frozen_string_literal: true

module PublicLibrary
  module Entities
    class OrderStatusChanges < Grape::Entity
      expose :id
      expose :status
      expose :status_key
      expose :changed_at

      def changed_at
        object.created_at
      end

      def status
        options[:locale] == :en ? object.order_status&.patron_status : object.order_status&.bn_patron_status
      end

      def status_key
        object.order_status&.status_key
      end
    end
  end
end

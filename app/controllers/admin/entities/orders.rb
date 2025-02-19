# frozen_string_literal: true

module Admin
  module Entities
    class Orders < Grape::Entity
      expose :id
      expose :user
      expose :library
      expose :recipient_phone
      expose :total
      expose :status
      expose :delivery_type
      expose :item_count
      expose :created_at
      expose :line_items, using: Admin::Entities::LineItems

      def user
        object.user&.as_json(only: %i[id full_name])
      end

      def library
        object.library&.as_json(only: %i[id name])
      end

      def item_count
        object.line_items.count
      end

      def status
        object.order_status&.admin_status
      end
    end
  end
end

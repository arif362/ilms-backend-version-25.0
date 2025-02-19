module Lms
  module Entities
    class Orders < Grape::Entity
      expose :id
      expose :unique_id
      expose :user
      expose :total
      expose :status
      expose :delivery_type
      expose :item_count
      expose :created_at

      def user
        object.user&.as_json(only: [:id, :full_name])
      end

      def item_count
        object.line_items.count
      end

      def status
        object.order_status&.lms_status
      end
    end
  end
end

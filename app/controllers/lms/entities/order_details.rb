# frozen_string_literal: true

module Lms
  module Entities
    class OrderDetails < Grape::Entity
      expose :id
      expose :unique_id
      expose :line_items, using: Lms::Entities::LineItems
      expose :user, using: Lms::Entities::UserList
      expose :total
      expose :status
      expose :note
      expose :created_at
      expose :delivery_type
      expose :recipient_name
      expose :recipient_phone
      expose :address_type
      expose :address
      expose :thana, using: Lms::Entities::Thanas
      expose :district, using: Lms::Entities::Districts
      expose :division, using: Lms::Entities::Divisions
      expose :order_status_changes, using: Lms::Entities::OrderStatusChanges

      def status
        object.order_status&.admin_status
      end
    end
  end
end

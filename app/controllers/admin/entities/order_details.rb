# frozen_string_literal: true

module Admin
  module Entities
    class OrderDetails < Grape::Entity
      expose :id
      expose :line_items, using: Admin::Entities::LineItems
      expose :user, using: Admin::Entities::UserList
      expose :library, using: Admin::Entities::Libraries
      expose :pick_up_library, using: Admin::Entities::Libraries
      expose :total
      expose :status
      expose :note
      expose :created_at
      expose :delivery_type
      expose :recipient_name
      expose :recipient_phone
      expose :address_type
      expose :address
      expose :delivery_area
      expose :delivery_area_id
      expose :tracking_id
      expose :thana, using: Admin::Entities::Thanas
      expose :district, using: Admin::Entities::Districts
      expose :division, using: Admin::Entities::Divisions
      expose :order_status_changes, using: Admin::Entities::OrderStatusChanges

      def status
        object.order_status&.admin_status
      end

      def pick_up_library
        Library.find_by(id: object&.pick_up_library_id)
      end
    end
  end
end

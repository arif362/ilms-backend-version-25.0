# frozen_string_literal: true

module PublicLibrary
  module Entities
    class OrderDetails < Grape::Entity
      expose :id
      expose :unique_id
      expose :total
      expose :status
      expose :status_key
      expose :note
      expose :placed_at
      expose :delivery_type
      expose :recipient_name
      expose :recipient_phone
      expose :address_type
      expose :address
      expose :library, using: PublicLibrary::Entities::LibraryList, as: :base_library
      expose :pick_up_library, using: PublicLibrary::Entities::LibraryList
      expose :thana, using: PublicLibrary::Entities::Thanas
      expose :district, using: PublicLibrary::Entities::Districts
      expose :division, using: PublicLibrary::Entities::Divisions
      expose :order_items
      expose :pay_type
      expose :trx_id
      expose :invoice_id
      expose :pay_status
      expose :delivery_area
      expose :delivery_area_id
      expose :tracking_id

      def placed_at
        object.created_at
      end

      def status_key
        object.order_status&.status_key
      end

      def status
        options[:locale] == :en ? object.order_status&.patron_status : object.order_status&.bn_patron_status
      end

      def order_items
        PublicLibrary::Entities::OrderItems.represent(object.line_items, locale: options[:locale], request_source: options[:request_source])
      end

      def trx_id
        object.invoices.paid&.last&.payments&.success&.last&.trx_id
      end

      def invoice_id
        object.invoices&.last&.id
      end

      def pick_up_library
        Library.find_by(id: object&.pick_up_library_id)
      end
    end
  end
end

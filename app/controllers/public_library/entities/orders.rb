module PublicLibrary
  module Entities
    class Orders < Grape::Entity
      expose :id
      expose :unique_id
      expose :user
      expose :library
      expose :total
      expose :status
      expose :status_key
      expose :delivery_type
      expose :item_count
      expose :created_at
      expose :order_items

      def user
        object.user&.as_json(only: [:id, :full_name])
      end

      def library
        object.library&.as_json(only: [:id, :name])
      end

      def item_count
        object.line_items.count
      end

      def status
        options[:locale] == :en ? object.order_status&.patron_status : object.order_status&.bn_patron_status
      end

      def status_key
        object.order_status&.status_key
      end

      def order_items
        PublicLibrary::Entities::OrderItems.represent(object.line_items, locale: options[:locale], request_source: options[:request_source])
      end
    end
  end
end

# frozen_string_literal: true

module Admin
  module Entities
    class GoodsReceipts < Grape::Entity

      expose :id
      expose :publisher
      expose :memorandum_publisher
      expose :publisher_biblios
      expose :quantity
      expose :price
      expose :sub_total
      expose :bar_code
      expose :purchase_code
      expose :purchase_order_status

      def publisher
        object&.publisher
      end

      def publisher_biblios
        object&.publisher&.publisher_biblios
      end

      def memorandum_publisher
        object&.memorandum_publisher
      end

      def purchase_order_line_items
        object&.po_line_items
      end

      def purchase_order_status
        object&.purchase_order&.purchase_order_status&.admin_status
      end
    end
  end
end

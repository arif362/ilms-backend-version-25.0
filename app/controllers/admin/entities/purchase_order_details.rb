# frozen_string_literal: true

module Admin
  module Entities
    class PurchaseOrderDetails < Grape::Entity

      expose :id
      expose :memorandum
      expose :status
      expose :publisher
      expose :memorandum_publisher
      expose :purchase_order_line_items, using: Admin::Entities::PurchaseOrderLineItemDetails
      expose :publisher_biblios


      def memorandum
        memorandum = object&.memorandum
        return if memorandum.nil?

        {
          id: memorandum.id,
          memorandum_no: memorandum.memorandum_no,
          start_date: memorandum.start_date,
          end_date: memorandum.end_date,
          start_time: memorandum.start_time,
          end_time: memorandum.end_time,
          tender_session: memorandum.tender_session,
        }

      end

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

      def status
        object&.purchase_order_status&.admin_status
      end
    end
  end
end

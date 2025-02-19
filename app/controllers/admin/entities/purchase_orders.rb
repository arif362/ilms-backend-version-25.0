# frozen_string_literal: true

module Admin
  module Entities
    class PurchaseOrders < Grape::Entity

      expose :id
      expose :memorandum
      expose :status
      expose :publisher


      def memorandum
        memorandum = object&.memorandum
        return if memorandum.nil?

        {
          id: memorandum.id,
          memorandum_no: memorandum.memorandum_no,
          tender_session: memorandum.tender_session
        }

      end

      def publisher
        publisher = object&.publisher
        return if publisher.nil?

        {
          id: publisher.id,
          publication_name: publisher.publication_name,
          publisher_name: publisher.name
        }
      end

      def status
        object&.purchase_order_status&.admin_status
      end
    end
  end
end

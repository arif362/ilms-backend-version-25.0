# frozen_string_literal: true

module Admin
  module Entities
    class ReceivedBooks < Grape::Entity

      expose :id
      expose :purchase_order
      expose :publisher
      expose :memorandum_publisher
      expose :memorandum
      expose :publisher_biblio
      expose :po_line_item
      expose :received_quantity
      expose :has_accession_number_quantity
      expose :not_sent_to_library_quantity
      expose :accession_number_list

      def purchase_order
        purchase_order = object&.purchase_order
        return if purchase_order.nil?

        {
          id: purchase_order.id,
          last_submission_date: purchase_order.last_submission_date
        }
      end

      def memorandum
        memorandum = object&.memorandum_publisher&.memorandum
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
          name: publisher.name,
          author_name: publisher.author_name,
          address: publisher.address,
          user_id: 20
        }
      end

      def memorandum_publisher
        memorandum_publisher = object&.memorandum_publisher
        return if memorandum_publisher.nil?

        {
          id: memorandum_publisher.id,
          track_no: memorandum_publisher.track_no
        }
      end

      def publisher_biblio
        object&.publisher_biblio
      end

      def po_line_item
        po_line_item = object&.po_line_item
        return if po_line_item.nil?

        {
          id: po_line_item.id,
          purchase_order_id: po_line_item.purchase_order_id,
          publisher_biblio_id: po_line_item.publisher_biblio_id,
          quantity: po_line_item.quantity,
          price: po_line_item.price,
          received_at: po_line_item.received_at,
          sub_total: po_line_item.sub_total,
          bar_code: po_line_item.bar_code,
          purchase_code: po_line_item.purchase_code,
        }
      end

      def received_quantity
        object&.received_quantity
      end

      def has_accession_number_quantity
        object&.has_accession_number_quantity
      end

      def accession_number_list
        object&.department_biblio_items.where.not(central_accession_no: nil).pluck(:central_accession_no)
      end

      def not_sent_to_library_quantity
        object&.not_sent_to_library_quantity
      end
    end
  end
end

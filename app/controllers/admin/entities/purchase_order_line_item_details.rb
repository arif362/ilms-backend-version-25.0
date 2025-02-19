# frozen_string_literal: true

module Admin
  module Entities
    class PurchaseOrderLineItemDetails < Grape::Entity

      expose :id
      expose :purchase_order_id
      expose :publisher_biblio
      expose :order_quantity
      expose :received_quantity
      expose :price
      expose :received_at
      expose :sub_total
      expose :bar_code
      expose :purchase_code

      def publisher_biblio
        line_publisher_biblio = object&.publisher_biblio
        return unless line_publisher_biblio.present?

        {
          id: line_publisher_biblio.id,
          title: line_publisher_biblio.title,
          author_name: line_publisher_biblio.author_name
        }
      end

      def order_quantity
        object.quantity
      end

    end
  end
end

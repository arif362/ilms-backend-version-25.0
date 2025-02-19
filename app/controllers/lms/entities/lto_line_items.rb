# frozen_string_literal: true

module Lms
  module Entities
    class LtoLineItems < Grape::Entity
      expose :id
      expose :quantity
      expose :price
      expose :library_transfer_order_id
      expose :created_at
      expose :updated_at
      expose :biblio
      expose :biblio_item

      def biblio
        object.biblio.as_json(only: %i[id title isbn])
      end

      def biblio_item
        return {} unless object.biblio_item.present?

        object.biblio_item&.as_json(only: %i[id barcode copy_number accession_no price])
      end
    end
  end
end

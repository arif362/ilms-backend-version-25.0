# frozen_string_literal: true

module Admin
  module Entities
    class PublisherBiblios < Grape::Entity

      expose :id
      expose :title
      expose :author_name
      expose :price
      expose :quantity
      expose :purchase_order


      def purchase_order
        purchase_order = object&.memorandum_publisher&.purchase_order
        {
          id: purchase_order&.id,
          memorandum_id: purchase_order&.memorandum_id,
          publisher_id: purchase_order&.publisher_id,
          memorandum_publisher_id: purchase_order&.memorandum_publisher_id,
          last_submission_date: purchase_order&.last_submission_date,
        }
      end
    end
  end
end

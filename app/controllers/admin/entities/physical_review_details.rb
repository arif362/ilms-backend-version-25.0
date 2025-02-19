# frozen_string_literal: true

module Admin
  module Entities
    class PhysicalReviewDetails < Grape::Entity
      include Admin::Helpers::ImageHelpers
      expose :id
      expose :user
      expose :biblio_item
      expose :review_body
      expose :book_image_url


      def biblio_item
        biblio_item = BiblioItem.find_by(id: object.biblio_item_id)
        return if biblio_item.nil?


        more_authors = biblio_item.biblio.authors.pluck(:first_name)
        {
          barcode: biblio_item.barcode,
          book_name: biblio_item.biblio&.title,
          authors: more_authors
        }
      end

      def user
        user = User.find_by(id: object.user_id)
        return if user.nil?

        {
          id: user&.id,
          unique_id: user&.unique_id
        }
      end

      def book_image_url
        image_path(object.book_image)
      end
    end
  end
end

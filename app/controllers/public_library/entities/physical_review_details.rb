# frozen_string_literal: true

module PublicLibrary
  module Entities
    class PhysicalReviewDetails < Grape::Entity
      include Admin::Helpers::ImageHelpers
      expose :id
      expose :biblio_item
      expose :review_body
      expose :created_at
      expose :book_image_url
      expose :library_id


      def biblio_item
        biblio_item = BiblioItem.find_by(id: object.biblio_item_id)
        return if biblio_item.nil?

        {
          book_name: biblio_item.biblio&.title,
          barcode: biblio_item.barcode,
          author_name: biblio_item.biblio.authors.pluck(:first_name)
        }
      end



      def book_image_url
        image_path(object.book_image)
      end
    end
  end
end

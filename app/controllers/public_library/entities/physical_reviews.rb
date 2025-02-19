# frozen_string_literal: true

module PublicLibrary
  module Entities
    class PhysicalReviews < Grape::Entity
      include Admin::Helpers::ImageHelpers
      expose :id
      expose :biblio_item
      expose :library_id


      def biblio_item
        biblio_item = BiblioItem.find_by(id: object.biblio_item_id)
        return if biblio_item.nil?

        author_name = biblio_item.biblio.authors&.map do |author|
          {
            id: author&.id,
            name: author&.full_name
          }

        end

        {
          book_name: biblio_item.biblio&.title,
          barcode: biblio_item.barcode,
          author_name:
        }
      end
    end
  end
end

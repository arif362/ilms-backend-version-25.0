# frozen_string_literal: true

module Admin
  module Entities
    class PhysicalReviews < Grape::Entity
      include Admin::Helpers::ImageHelpers
      expose :id
      expose :user
      expose :biblio_item
      expose :review_body


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
          barcode: biblio_item.barcode,
          book_name: biblio_item.biblio&.title,
          author_name: author_name
        }
      end

      def user
        user = User.find_by(id: object.user_id)
        return if user.nil?

        {
          id: user&.id,
          unique_id: user&.unique_id,
        }
      end

    end
  end
end

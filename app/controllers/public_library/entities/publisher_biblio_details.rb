# frozen_string_literal: true

module PublicLibrary
  module Entities
    class PublisherBiblioDetails < Grape::Entity

      expose :id
      expose :title
      expose :authors
      expose :publisher_name
      expose :publisher_phone
      expose :publisher_address
      expose :publication_date
      expose :publisher_website
      expose :edition
      expose :print
      expose :total_page
      expose :subject
      expose :price
      expose :isbn
      expose :paper_type
      expose :binding_type
      expose :is_foreign
      expose :comment
      expose :memorandum, if: { expose_memorandum: true }

      def memorandum
        memorandum = object&.memorandum_publisher&.memorandum
        {
          id: memorandum&.id,
          memorandum_no: memorandum&.memorandum_no
        }
      end

      def authors
        object.author_name.split(',')
      end
    end
  end
end

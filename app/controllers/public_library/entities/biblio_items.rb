# frozen_string_literal: true


module PublicLibrary
  module Entities
    class BiblioItems < Grape::Entity
      expose :id
      expose :barcode
      expose :biblio_item
      expose :library

      def biblio_item
        biblio = object&.biblio
        return if biblio.nil?

        {
          id: biblio.id,
          book_name: biblio.title,
          author_name: biblio.authors.pluck(:first_name)
        }
      end

      def library
        library = object&.library
        return if library.nil?

        {
          id: library.id,
          name: library.name
        }
      end
    end
  end
end


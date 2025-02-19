module Admin
  module Entities
    class LostDamagedBiblios < Grape::Entity
      expose :id
      expose :biblio_title
      expose :created_at, as: :damaged_at
      expose :price
      expose :status
      expose :request_type
      expose :accession_no
      expose :library

      def isbn
        object.biblio_item&.biblio&.isbn
      end

      def biblio_title
        object.biblio_item&.biblio&.title
      end

      def price
        object.biblio_item&.price
      end

      def accession_no
        object.biblio_item&.accession_no
      end

      def library
        object.library.as_json(only: %i[id name code])
      end

    end
  end
end

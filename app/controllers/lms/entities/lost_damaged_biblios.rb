module Lms
  module Entities
    class LostDamagedBiblios < Grape::Entity
      expose :id
      expose :biblio_title
      expose :created_at, as: :damaged_at
      expose :price
      expose :isbn
      expose :status
      expose :request_type
      expose :invoice

      def isbn
        object.biblio_item&.biblio&.isbn
      end

      def biblio_title
        object.biblio_item&.biblio&.title
      end

      def price
        object.biblio_item&.price
      end

    end
  end
end

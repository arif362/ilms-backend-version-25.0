# frozen_string_literal: true

module Lms
  module Entities
    class BookTransferOrders < Grape::Entity
      expose :id
      expose :biblio
      expose :receiver_library
      expose :status

      def biblio
        biblio = object.biblio
        {
          id: biblio&.id,
          slug: biblio&.slug,
          title: biblio&.title
        }
      end

      def receiver_library
        receiver_library = object.library
        {
          id: receiver_library&.id,
          name: receiver_library&.name,
          code: receiver_library&.code
        }
      end
    end
  end
end

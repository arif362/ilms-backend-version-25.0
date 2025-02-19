# frozen_string_literal: true

module PublicLibrary
  module Entities
    class MemorandumPublisherDetails < Grape::Entity

      expose :id
      expose :memorandum
      expose :publisher, using: PublicLibrary::Entities::Publishers
      expose :is_final_submitted
      expose :publisher_biblios

      def memorandum
        memorandum = object&.memorandum
        {
          id: memorandum&.id,
          memorandum_no: memorandum&.memorandum_no
        }
      end

      def publisher_biblios
        PublicLibrary::Entities::PublisherBiblioDetails.represent(object.publisher_biblios, expose_memorandum: false)
      end
    end
  end
end

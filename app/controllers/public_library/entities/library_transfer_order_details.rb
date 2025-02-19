# frozen_string_literal: true

module PublicLibrary
  module Entities
    class LibraryTransferOrderDetails < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers
      expose :id
      expose :biblio
      expose :receiver_library
      expose :status
      expose :arrived_at
      expose :created_at

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
          name: locale == :en ? receiver_library&.name : receiver_library&.bn_name,
          code: receiver_library&.code
        }
      end

      def locale
        options[:locale]
      end
    end
  end
end

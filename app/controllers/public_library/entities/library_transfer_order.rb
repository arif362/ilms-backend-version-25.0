# frozen_string_literal: true

module PublicLibrary
  module Entities
    class LibraryTransferOrder < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers
      expose :id
      expose :biblio
      expose :status
      expose :arrived_at

      def biblio
        object.biblio&.title
      end

      def locale
        options[:locale]
      end
    end
  end
end

# frozen_string_literal: true

module PublicLibrary
  module Entities
    class RequestedBiblios < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :id
      expose :biblio_title
      expose :authors
      expose :isbn
      expose :possible_availability_at


      def authors
        authors = if locale == :en
                    object&.authors&.map(&:full_name)
                  else
                    object&.authors&.map(&:bn_full_name)
                  end
        authors.concat(Array(object&.authors_name))
      end

      def locale
        options[:locale]
      end
    end
  end
end

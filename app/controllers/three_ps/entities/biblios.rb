# frozen_string_literal: true

module ThreePs
  module Entities
    class Biblios < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :title
      expose :subtitle
      expose :image
      expose :url
      expose :buttons

      def subtitle
        if object.authors.present?
          object.authors.map(&:full_name).uniq&.join(', ')
        elsif object.biblio_publication.present?
          object.biblio_publication&.title
        end
      end

      def image
        mobile_cart_image(object.image)
      end

      def url
        "#{ENV['ROOT_URL']}/books/#{object.slug}"
      end

      def buttons
        [
          {
            title: 'Show Details',
            type: 'url',
            value: "#{ENV['ROOT_URL']}/books/#{object.slug}"
          }
        ]
      end
    end
  end
end

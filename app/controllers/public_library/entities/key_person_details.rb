# frozen_string_literal: true

module PublicLibrary
  module Entities
    class KeyPersonDetails < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers
      expose :slug
      expose :name
      expose :designation
      expose :description
      expose :position
      expose :image_url

      def name
        locale == :en ? object.name : object.bn_name
      end

      def designation
        locale == :en ? object.designation : object.bn_designation
      end

      def description
        locale == :en ? object.description : object.bn_description
      end

      def image_url
        web_images = { desktop_image: desktop_large_image(object.image), tab_image: tab_large_image(object.image) }
        options[:request_source] == :app ? mobile_large_image(object.image) : web_images
      end

      def locale
        options[:locale]
      end
    end
  end
end

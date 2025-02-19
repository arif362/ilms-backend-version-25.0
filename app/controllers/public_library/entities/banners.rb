# frozen_string_literal: true

module PublicLibrary
  module Entities
    class Banners < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers
      expose :title
      expose :slug
      expose :image_url

      def title
        locale == :en ? object.title : object.bn_title
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

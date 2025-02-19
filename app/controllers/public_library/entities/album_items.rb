# frozen_string_literal: true

module PublicLibrary
  module Entities
    class AlbumItems < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :id
      expose :caption
      expose :image_url
      expose :video_link

      def caption
        locale == :en ? object&.caption : object&.bn_caption
      end

      def image_url
        web_image = { desktop_image: desktop_cart_image(object.image), tab_image: tab_cart_image(object.image), full_image: image_path(object.image) }
        options[:request_source] == :app ? mobile_large_image(object.image) : web_image
      end

      def locale
        options[:locale]
      end
    end
  end
end

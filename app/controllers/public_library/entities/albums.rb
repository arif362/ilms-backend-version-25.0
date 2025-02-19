# frozen_string_literal: true

module PublicLibrary
  module Entities
    class Albums < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :id
      expose :title
      expose :album_type
      expose :total_items
      expose :slug
      expose :thumbnail_url

      def title
        locale == :en ? object.title : object.bn_title
      end

      def thumbnail_url
        web_image = { desktop_image: desktop_cart_image(object.image), tab_image: tab_cart_image(object.image) }
        options[:request_source] == :app ? mobile_cart_image(object.image) : web_image
      end

      def locale
        options[:locale]
      end
    end
  end
end

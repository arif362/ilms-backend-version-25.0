# frozen_string_literal: true

module PublicLibrary
  module Entities
    class Events < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers
      format_with(:iso_date, &:to_date)

      expose :title
      expose :slug
      expose :start_date, format_with: :iso_date
      expose :end_date, format_with: :iso_date
      expose :details
      expose :is_local
      expose :image_url

      def title
        locale == :en ? object.title : object.bn_title
      end

      def details
        locale == :en ? object.details : object.bn_details
      end

      def image_url
        web_image = { desktop_image: desktop_cart_image(object.image), tab_image: tab_cart_image(object.image) }
        options[:request_source] == :app ? mobile_cart_image(object.image) : web_image
      end

      def locale
        options[:locale]
      end
    end
  end
end

# frozen_string_literal: true

module PublicLibrary
  module Entities
    class HomepageSliders < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers
      expose :title
      expose :link
      expose :serial_no
      expose :image_url

      def image_url
        web_images = { desktop_image: desktop_large_image(object.image), tab_image: tab_large_image(object.image) }
        options[:request_source] == :app ? mobile_large_image(object.image) : web_images
      end
    end
  end
end

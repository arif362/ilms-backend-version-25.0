# frozen_string_literal: true

module Admin
  module Entities
    class HomepageSliders < Grape::Entity
      include Admin::Helpers::ImageHelpers

      expose :id
      expose :title
      expose :is_visible
      expose :link
      expose :serial_no
      expose :image_url

      def image_url
        desktop_large_image(object.image)
      end
    end
  end
end

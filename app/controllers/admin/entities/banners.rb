# frozen_string_literal: true

module Admin
  module Entities
    class Banners < Grape::Entity
      include Admin::Helpers::ImageHelpers

      expose :id
      expose :title
      expose :bn_title
      expose :slug
      expose :is_visible
      expose :page_type
      expose :position
      expose :image_url

      def page_type
        page_type = object.page_type
        {
          id: page_type&.id,
          title: page_type&.title
        }
      end

      def image_url
        mobile_cart_image(object.image)
      end
    end
  end
end

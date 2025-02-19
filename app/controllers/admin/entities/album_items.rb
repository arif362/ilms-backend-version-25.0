# frozen_string_literal: true

module Admin
  module Entities
    class AlbumItems < Grape::Entity
      include Admin::Helpers::ImageHelpers

      expose :id
      expose :caption
      expose :bn_caption
      expose :image
      expose :video_link, as: :video

      def image
        mobile_cart_image(object&.image)
      end
    end
  end
end

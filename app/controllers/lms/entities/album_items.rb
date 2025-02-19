# frozen_string_literal: true

module Lms
  module Entities
    class AlbumItems < Grape::Entity
      include Lms::Helpers::ImageHelpers

      expose :id
      expose :caption
      expose :bn_caption
      expose :image
      expose :video_link, as: :video

      def image
        mobile_cart_image(object&.image)
      end

      def video
        video_preview(object&.video)
      end
    end
  end
end

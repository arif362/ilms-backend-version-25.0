# frozen_string_literal: true

module Lms
  module Entities
    class AlbumDetails < Grape::Entity
      include Lms::Helpers::ImageHelpers

      expose :id
      expose :title
      expose :bn_title
      expose :is_visible
      expose :album_type
      expose :is_event_album
      expose :event
      expose :status
      expose :published_at
      expose :thumbnail
      expose :album_items, using: Lms::Entities::AlbumItems

      def event
        event = object&.event
        {
          id: event&.id,
          title: event&.title,
          start_date: event&.start_date,
          end_date: event&.end_date
        }
      end

      def thumbnail
        mobile_cart_image(object.image)
      end
    end
  end
end

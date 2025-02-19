# frozen_string_literal: true

module Admin
  module Entities
    class AlbumDetails < Grape::Entity
      include Admin::Helpers::ImageHelpers

      expose :id
      expose :title
      expose :bn_title
      expose :is_visible
      expose :album_type
      expose :is_event_album
      expose :library
      expose :event
      expose :status
      expose :published_at
      expose :thumbnail
      expose :album_items, using: Admin::Entities::AlbumItems

      def library
        library = object&.library
        {
          id: library&.id,
          name: library&.name
        }
      end

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

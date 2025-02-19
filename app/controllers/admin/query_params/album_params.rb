# frozen_string_literal: true

module Admin
  module QueryParams
    module AlbumParams
      extend ::Grape::API::Helpers

      params :album_create_params do
        requires :title, type: String
        requires :bn_title, type: String
        requires :image_file, type: File
        requires :album_type, type: String, values: %w[photo video]
        requires :is_event_album, type: Boolean
        requires :album_items_attributes, type: Array do
          requires :caption, type: String
          requires :bn_caption, type: String
          optional :video_link, type: String
          optional :image_file, type: File
        end
        requires :is_visible, type: Boolean, default: true
        optional :event_id, type: Integer
      end

      params :album_update_params do
        requires :title, type: String
        requires :bn_title, type: String
        requires :album_type, type: String, values: %w[photo video]
        requires :is_event_album, type: Boolean
        optional :album_items_attributes, type: Array do
          optional :id, type: Integer
          requires :caption, type: String
          requires :bn_caption, type: String
          optional :video_link, type: String
          optional :image_file, type: File
          optional :_destroy, type: Boolean, default: false
        end
        optional :image_file, type: File
        optional :is_visible, type: Boolean
        optional :event_id, type: Integer
      end
    end
  end
end

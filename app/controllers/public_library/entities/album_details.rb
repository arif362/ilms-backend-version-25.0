# frozen_string_literal: true

module PublicLibrary
  module Entities
    class AlbumDetails < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :id
      expose :title
      expose :album_type
      expose :library
      expose :published_at
      expose :slug
      expose :album_items, using: PublicLibrary::Entities::AlbumItems

      def title
        locale == :en ? object.title : object.bn_title
      end

      def library
        library = object&.library
        {
          id: library&.id,
          name: locale == :en ? library&.name : library&.bn_name
        }
      end

      def locale
        options[:locale]
      end
    end
  end
end

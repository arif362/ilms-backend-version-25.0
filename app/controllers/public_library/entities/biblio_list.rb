# frozen_string_literal: true

module PublicLibrary
  module Entities
    class BiblioList < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :id
      expose :title
      expose :is_wishlisted
      expose :slug
      expose :isbn
      expose :series_statement_volume
      expose :biblio_publication
      expose :authors, using: PublicLibrary::Entities::Authors
      expose :average_rating
      expose :total_reviews
      expose :image_url
      expose :full_ebook_file_url
      expose :item_type

      def biblio_publication
        publication = BiblioPublication.find_by(id: object.biblio_publication_id)
        locale == :en ? publication&.title : publication&.bn_title
      end

      def image_url
        web_images = { desktop_image: desktop_cart_image(object.image), tab_image: tab_cart_image(object.image) }
        options[:request_source] == :app ? mobile_cart_image(object.image) : web_images
      end

      def locale
        options[:locale]
      end

      def current_user
        options[:current_user]
      end

      def is_wishlisted
        object.wishlisted?(current_user)
      end
    end
  end
end

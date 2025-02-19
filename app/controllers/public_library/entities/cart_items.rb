module PublicLibrary
  module Entities
    class CartItems < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :id
      expose :biblio_id
      expose :title
      expose :slug
      expose :authors
      expose :image_url

      def slug
        biblio.slug
      end

      def biblio_id
        biblio.id
      end

      def title
        biblio&.title || ''
      end

      def image_url
        return if biblio.nil?

        web_images = { desktop_image: desktop_cart_image(biblio&.image), tab_image: tab_cart_image(biblio&.image) }
        options[:request_source] == :app ? mobile_cart_image(biblio&.image) : web_images
      end

      def authors
        PublicLibrary::Entities::Authors.represent(biblio&.authors, locale: options[:locale])
      end

      def biblio
        object.biblio
      end

    end
  end
end

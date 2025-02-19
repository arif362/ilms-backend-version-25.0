module ThreePs
  module Entities
    class OrderItems < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :id
      expose :title
      expose :image_url

      def title
        biblio&.title || ''
      end

      def image_url
        return if biblio.nil?

        { desktop_image: desktop_cart_image(biblio&.image), tab_image: tab_cart_image(biblio&.image) }

      end

      def biblio
        object.biblio
      end

    end
  end
end

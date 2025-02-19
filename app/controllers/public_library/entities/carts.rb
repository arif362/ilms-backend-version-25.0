module PublicLibrary
  module Entities
    class Carts < Grape::Entity
      expose :id, as: :cart_id
      expose :cart_items

      def cart_items
        PublicLibrary::Entities::CartItems.represent(object.cart_items, locale: options[:locale], request_source: options[:request_source])
      end

    end
  end
end

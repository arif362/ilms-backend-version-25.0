# frozen_string_literal: true

module PublicLibrary
  module Entities
    class ReviewList < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :id
      expose :text
      expose :rating
      expose :user
      expose :biblio
      expose :created_at
      expose :status

      def user
        user = User.find_by(id: object.user_id)
        {
          id: user.id,
          name: user.full_name,
          image_url: desktop_cart_image(object.user&.image)
        }
      end

      def biblio
        object.biblio.as_json(only: %i[id title])
      end
    end
  end
end

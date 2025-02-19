# frozen_string_literal: true

module Admin
  module Entities
    class RequestedBiblioDetails < Grape::Entity
      include Admin::Helpers::ImageHelpers

      expose :user
      expose :biblio_title
      expose :authors
      expose :biblio_subjects
      expose :isbn
      expose :publication
      expose :edition
      expose :volume
      expose :image
      expose :possible_availability_at

      def biblio_subjects
        object&.biblio_subjects&.pluck(:personal_name).concat(object&.biblio_subjects_name)
      end

      def authors
        object&.authors&.map(&:full_name).concat(Array(object&.authors_name))
      end

      def user
        {
          id: object.user_id,
          name: object.user&.full_name,
          unique_id: object.user&.unique_id
        }
      end

      def image
        mobile_cart_image(object.image)
      end
    end
  end
end

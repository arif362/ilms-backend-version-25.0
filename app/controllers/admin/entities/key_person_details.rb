# frozen_string_literal: true

module Admin
  module Entities
    class KeyPersonDetails < Grape::Entity
      include Admin::Helpers::ImageHelpers
      expose :id
      expose :name
      expose :bn_name
      expose :slug
      expose :designation
      expose :bn_designation
      expose :description
      expose :bn_description
      expose :is_active
      expose :position
      expose :image_url

      def image_url
        mobile_large_image(object.image)
      end
    end
  end
end

module Admin
  module Entities
    class Pages < Grape::Entity
      include Admin::Helpers::ImageHelpers

      expose :id
      expose :title
      expose :slug
      expose :bn_title
      expose :description
      expose :bn_description
      expose :is_active
      expose :is_deletable
      expose :created_at
      expose :banner_url

      def banner_url
        image_path(object.image)
      end
    end
  end
end

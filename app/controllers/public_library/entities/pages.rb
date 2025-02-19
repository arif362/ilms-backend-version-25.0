module PublicLibrary
  module Entities
    class Pages < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :id
      expose :title
      expose :description
      expose :is_active
      expose :slug
      expose :created_at
      expose :banner_url

      def title
        locale == :en ? object.title : object.bn_title
      end

      def description
        locale == :en ? object.description : object.bn_description
      end
      def banner_url
        banner_image(object.image)
      end

      def locale
        options[:locale]
      end

    end
  end
end

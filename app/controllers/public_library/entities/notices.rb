module PublicLibrary
  module Entities
    class Notices < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :id
      expose :title
      expose :description
      expose :published_date
      expose :document_url
      expose :slug

      def title
        options[:locale] == :en ? object.title : object.bn_title
      end

      def description
        options[:locale] == :en ? object.description : object.bn_description
      end

      def document_url
        image_path(object.document)
      end
    end
  end
end
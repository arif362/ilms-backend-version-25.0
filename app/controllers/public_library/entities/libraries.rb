# frozen_string_literal: true

module PublicLibrary
  module Entities
    class Libraries < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers
      expose :name
      expose :code
      expose :description
      expose :phone
      expose :created_at
      expose :district
      expose :thana
      expose :lat
      expose :long
      expose :address
      expose :library_images
      expose :hero_image_url

      def name
        locale == :en ? object.name : object.bn_name
      end

      def description
        locale == :en ? object.description : object.bn_description
      end


      def district
        if locale == :en
          object.thana.district.as_json(only: %i[id name])
        else
          object.thana.district.as_json(only: %i[id bn_name])
        end
      end

      def thana
        if locale == :en
          object.thana.as_json(only: %i[id name])
        else
          object.thana.as_json(only: %i[id bn_name])
        end
      end

      def library_images
        library_images = library_details_images(object.images)
        library_images.nil? ? [] : library_images
      end

      def hero_image_url
        thumb_image(object.hero_image)
      end

      def locale
        options[:locale]
      end
    end
  end
end

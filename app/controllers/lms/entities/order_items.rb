# frozen_string_literal: true

module Lms
  module Entities
    class OrderItems < Grape::Entity
      include Lms::Helpers::ImageHelpers

      expose :id
      expose :title
      expose :image_url

      def title
        biblio&.title || ''
      end

      def image_url
        return if biblio.nil?

        mobile_large_image(biblio&.image)
      end

      def biblio
        object.biblio
      end
    end
  end
end

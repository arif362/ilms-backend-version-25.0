# frozen_string_literal: true

module Admin
  module Entities
    class Documents < Grape::Entity
      include Admin::Helpers::ImageHelpers

      expose :id
      expose :name
      expose :bn_name
      expose :description
      expose :bn_description
      expose :document_category
      expose :created_by
      expose :document_url


      private

      def created_by
        staff = Staff.find_by(id: object.created_by)

        return if staff.nil?

        {
          id: staff.id,
          name: staff.name
        }
      end

      def document_category
        {
          id: object.document_category_id,
          name: object.document_category&.name
        }
      end

      def document_url
        image_path(object.document)
      end
    end
  end
end

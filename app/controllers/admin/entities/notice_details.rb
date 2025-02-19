# frozen_string_literal: true

module Admin
  module Entities
    class NoticeDetails < Grape::Entity
      include Admin::Helpers::ImageHelpers

      expose :id
      expose :title
      expose :bn_title
      expose :description
      expose :bn_description
      expose :is_published
      expose :published_date
      expose :published_by
      expose :created_by
      expose :updated_by
      expose :created_at
      expose :document_url
      expose :notice_type

      def published_by
        staff = Staff.find_by(id: object&.published_by_id)
        return nil unless staff.present?

        {
          "id": staff.id,
          "name": staff.name
        }
      end

      def created_by
        staff = Staff.find_by(id: object&.created_by_id)
        return nil unless staff.present?

        {
          "id": staff.id,
          "name": staff.name
        }
      end

      def updated_by
        staff = Staff.find_by(id: object&.updated_by_id)
        return nil unless staff.present?

        {
          "id": staff.id,
          "name": staff.name
        }
      end

      def document_url
        image_path(object.document)
      end
    end
  end
end

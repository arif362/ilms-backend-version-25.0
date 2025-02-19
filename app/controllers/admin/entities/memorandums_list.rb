# frozen_string_literal: true

module Admin
  module Entities
    class MemorandumsList < Grape::Entity
      include Admin::Helpers::ImageHelpers
      expose :id
      expose :memorandum_no
      expose :start_date
      expose :end_date
      expose :tender_session
      expose :is_visible

      def image_url
        image_path(object&.image)
      end

      def created_by
        created_by = Staff.find_by(id: object&.created_by_id)
        {
          id: created_by&.id || nil,
          title: created_by&.name || ''
        }
      end

      def updated_by
        updated_by = Staff.find_by(id: object&.updated_by_id)
        {
          id: updated_by&.id || nil,
          title: updated_by&.name || ''
        }
      end
    end
  end
end

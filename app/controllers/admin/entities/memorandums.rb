module Admin
  module Entities
    class Memorandums < Grape::Entity
      include Admin::Helpers::ImageHelpers
      expose :id
      expose :memorandum_no
      expose :start_date
      expose :end_date
      expose :start_time
      expose :end_time
      expose :tender_session
      expose :last_submission_date
      expose :created_by
      expose :updated_by
      expose :is_visible
      expose :image_url
      expose :description
      expose :total_submission

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

      def total_submission
        object.memorandum_publishers.submitted.count
      end
    end
  end
end

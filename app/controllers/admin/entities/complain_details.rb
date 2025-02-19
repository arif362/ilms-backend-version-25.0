# frozen_string_literal: true

module Admin
  module Entities
    class ComplainDetails < Grape::Entity
      include Admin::Helpers::ImageHelpers

      expose :id
      expose :complain_type
      expose :action_type
      expose :library
      expose :user
      expose :description
      expose :creation
      expose :images
      expose :closed_or_resolved_at
      expose :closed_or_resolved_by_staff_id


      def user
        return 'Guest' unless object.user_id.present?

        {
          id: object.user.id,
          name: object.user.full_name
        }
      end

      def creation
        {
          date: object.created_at.to_date,
          time: object.created_at.strftime('%H:%M')
        }
      end

      def library
        object.library&.name
      end


      def images
        complaint_images = complaint_images(object.images)
        complaint_images.nil? ? [] : complaint_images
      end
    end
  end
end

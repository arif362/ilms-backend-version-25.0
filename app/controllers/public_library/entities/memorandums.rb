module PublicLibrary
  module Entities
    class Memorandums < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers
      expose :id
      expose :memorandum_no
      expose :start_date
      expose :end_date
      expose :start_time
      expose :end_time
      expose :tender_session
      expose :last_submission_date
      expose :created_by_id
      expose :updated_by_id
      expose :description
      expose :is_visible
      expose :image_url
      expose :is_publisher_submitted
      def current_user
        options[:current_user]
      end

      def is_publisher_submitted
        return false unless current_user.present? && current_user.publisher.present?

        memorandun_publisher = object.memorandum_publishers.find_by(publisher_id: current_user.publisher.id)
        memorandun_publisher.present? ? memorandun_publisher.is_final_submitted : false
      end

      def image_url
        image_path(object&.image)
      end
    end
  end
end

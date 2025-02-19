# frozen_string_literal: true

module Lms
  module Entities
    class EventDetails < Grape::Entity
      include Lms::Helpers::ImageHelpers

      expose :id
      expose :title
      expose :bn_title
      expose :email
      expose :phone
      expose :details
      expose :bn_details
      expose :start_date
      expose :end_date
      expose :registration_last_date
      expose :is_published
      expose :is_local
      expose :is_registerable
      expose :registration_fields
      expose :total_registered
      expose :image_url
      expose :competition_info


      def image_url
        mobile_large_image(object.image)
      end

      def total_registered
        object.event_libraries&.sum(:total_registered)
      end
    end
  end
end

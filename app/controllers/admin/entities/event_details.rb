# frozen_string_literal: true

module Admin
  module Entities
    class EventDetails < Grape::Entity
      include Admin::Helpers::ImageHelpers

      expose :id
      expose :title
      expose :bn_title
      expose :slug
      expose :email
      expose :phone
      expose :details
      expose :bn_details
      expose :start_date
      expose :end_date
      expose :is_published
      expose :is_local
      expose :is_registerable
      expose :registration_last_date
      expose :registration_fields
      expose :competition_info
      expose :total_registered
      expose :image_url

      def image_url
        mobile_large_image(object.image)
      end

      def total_registered
        object.event_libraries&.sum(:total_registered)
      end
    end
  end
end

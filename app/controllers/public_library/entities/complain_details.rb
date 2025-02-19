# frozen_string_literal: true

module PublicLibrary
  module Entities
    class ComplainDetails < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers
      expose :id
      expose :complain_type
      expose :action_type
      expose :library
      expose :description
      expose :reply, expose_nil: false
      expose :created_at
      expose :images
      expose :closed_or_resolved_at
      expose :closed_or_resolved_by_staff_id
      expose :subject

      def created_at
        object.created_at.to_date
      end

      def library
        locale == :en ? object.library&.name : object.library&.bn_name
      end

      def locale
        options[:locale]
      end

      def images
        complaint_images = complaint_images(object.images)
        complaint_images.nil? ? [] : complaint_images
      end
    end
  end
end

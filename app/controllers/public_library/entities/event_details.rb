# frozen_string_literal: true

module PublicLibrary
  module Entities
    class EventDetails < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :user_registered
      expose :title
      expose :slug
      expose :email
      expose :phone
      expose :details
      expose :start_date
      expose :end_date
      expose :registration_last_date
      expose :organizer
      expose :venue
      expose :is_registerable
      expose :is_local
      expose :registration_fields
      expose :competition_info
      expose :image_url
      expose :albums, using: PublicLibrary::Entities::Albums do |instance|
        instance.albums&.approved
      end

      def title
        locale == :en ? object.title : object.bn_title
      end

      def details
        locale == :en ? object.details : object.bn_details
      end

      def image_url
        web_image = { desktop_image: desktop_large_image(object.image), tab_image: tab_large_image(object.image) }
        options[:request_source] == :app ? mobile_large_image(object.image) : web_image
      end

      def organizer
        if object.is_local
          library = object.event_libraries&.first&.library
          locale == :en ? library&.name : library&.bn_name
        else
          ENV['EVENT_ORGANIZER']
        end
      end

      def venue
        if object.is_local
          library = object.event_libraries&.first&.library
          locale == :en ? library&.address : library&.bn_address
        else
          ENV['EVENT_VENUE']
        end
      end

      def is_registerable
        object&.registration_last_date >= DateTime.now && object.is_registerable
      end

      def locale
        options[:locale]
      end

      def current_user
        options[:current_user]
      end

      def user_registered
        return false unless current_user.present?

        object.event_registrations.find_by(user_id: current_user&.id).present? ? true : false
      end

    end
  end
end

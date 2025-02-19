# frozen_string_literal: true

module PublicLibrary
  module Entities
    class RegisterdEventsDetails < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers
      format_with(:iso_date, &:to_date)

      expose :id
      expose :title
      expose :slug
      expose :start_date, format_with: :iso_date
      expose :end_date, format_with: :iso_date
      expose :details
      expose :is_local
      expose :image_url
      expose :registration_list
      expose :library_details

      def library_details
        return nil unless object.is_local

        object&.libraries&.last&.as_json(only: %i[id name code library_type])
      end
      def title
        locale == :en ? object.title : object.bn_title
      end

      def registration_list
        options[:user]&.event_registrations&.where(event_id: object&.id)&.as_json(only: %i[id email name phone address status identity_number competition_name participate_group father_name mother_name is_winner competition_name winner_position rejection_note created_at])
      end

      def details
        locale == :en ? object.details : object.bn_details
      end

      def image_url
        web_image = { desktop_image: desktop_cart_image(object.image), tab_image: tab_cart_image(object.image) }
        options[:request_source] == :app ? mobile_cart_image(object.image) : web_image
      end

      def locale
        options[:locale]
      end
    end
  end
end

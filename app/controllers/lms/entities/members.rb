# frozen_string_literal: true

module Lms
  module Entities
    class Members < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :id
      expose :user_type
      expose :unique_id
      expose :full_name
      expose :email
      expose :phone
      expose :dob
      expose :gender
      expose :member
      expose :saved_addresses
      expose :member_activated_at
      expose :image, as: :profile_image_url, format_with: :image_path

      def saved_addresses
        object&.saved_addresses
      end

      def member
        object&.member
      end

      def member_activated_at
        member&.activated_at
      end

      def user_type
        'Member'
      end
    end
  end
end

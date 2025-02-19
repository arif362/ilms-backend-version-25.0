# frozen_string_literal: true

module Lms
  module Entities
    class Users < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :id
      expose :user_type
      expose :unique_id
      expose :full_name
      expose :email
      expose :phone
      expose :dob
      expose :gender
      expose :saved_addresses
      expose :image, as: :profile_image_url, format_with: :image_path


      def saved_addresses
        object&.saved_addresses
      end

      def user_type
        'user'
      end
    end
  end
end

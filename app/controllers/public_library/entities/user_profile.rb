# frozen_string_literal: true

module PublicLibrary
  module Entities
    class UserProfile < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers
      format_with(:iso_date, &:to_date)

      expose :id
      expose :full_name
      expose :email
      expose :phone
      expose :dob, format_with: :iso_date
      expose :gender
      expose :image, as: :profile_image_url, format_with: :image_path
    end
  end
end

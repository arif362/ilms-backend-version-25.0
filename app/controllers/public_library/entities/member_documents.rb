# frozen_string_literal: true

module PublicLibrary
  module Entities
    class MemberDocuments < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :identity_number
      expose :nid_front_image, as: :nid_front_image_url, format_with: :image_path
      expose :nid_back_image, as: :nid_back_image_url, format_with: :image_path
      expose :birth_certificate_image, as: :birth_certificate_image_url, format_with: :image_path
      expose :student_id_image, as: :student_id_image_url, format_with: :image_path
      expose :verification_certificate_image, as: :verification_certificate_image_url, format_with: :image_path
    end
  end
end

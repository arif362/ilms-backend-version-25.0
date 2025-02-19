# frozen_string_literal: true

module Admin
  module Entities
    class RequestDetails < Grape::Entity
      include Admin::Helpers::ImageHelpers

      expose :id
      expose :library, using: Admin::Entities::Libraries
      expose :full_name
      expose :phone
      expose :gender
      expose :membership_category
      expose :dob
      expose :mother_name
      expose :father_Name
      expose :identity_type
      expose :identity_number
      expose :profession
      expose :institute_name
      expose :institute_address
      expose :student_class
      expose :student_section
      expose :student_id
      expose :present_address
      expose :present_division, using: Admin::Entities::Divisions
      expose :present_district, using: Admin::Entities::Districts
      expose :present_thana, using: Admin::Entities::Thanas
      expose :permanent_address
      expose :permanent_division, using: Admin::Entities::Divisions
      expose :permanent_district, using: Admin::Entities::Districts
      expose :permanent_thana, using: Admin::Entities::Thanas
      expose :card_delivery_type
      expose :delivery_address_type
      expose :recipient_name
      expose :recipient_phone
      expose :delivery_address
      expose :delivery_division, using: Admin::Entities::Divisions
      expose :delivery_district, using: Admin::Entities::Districts
      expose :delivery_thana, using: Admin::Entities::Thanas
      expose :status
      expose :images

      def images
        {
          profile_image: image_path(object.profile_image),
          nid_front_image: image_path(object.nid_front_image),
          nid_back_image: image_path(object.nid_back_image),
          birth_certificate_image: image_path(object.birth_certificate_image),
          student_id_image: image_path(object.student_id_image),
          verification_certificate_image: image_path(object.verification_certificate_image)
        }
      end
    end
  end
end

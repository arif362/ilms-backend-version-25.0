# frozen_string_literal: true

module Lms
  module Entities
    class MemberDetails < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :id
      expose :gender
      expose :father_Name
      expose :mother_name
      expose :profession
      expose :student_class
      expose :student_section
      expose :student_id
      expose :full_name
      expose :email
      expose :dob
      expose :identity_type
      expose :identity_number
      expose :institute_name
      expose :profile_image_url
      expose :nid_front_image_url
      expose :nid_back_image_url
      expose :birth_certificate_image_url
      expose :student_id_image_url

      def full_name
        object.user.full_name
      end

      def email
        object.user.email
      end

      def profile_image_url
        image_path(object.profile_image)
      end

      def nid_front_image_url
        image_path(object.nid_front_image)
      end

      def nid_back_image_url
        image_path(object.nid_back_image)
      end

      def birth_certificate_image_url
        image_path(object.birth_certificate_image)
      end

      def student_id_image_url
        image_path(object.student_id_image)
      end

    end
  end
end

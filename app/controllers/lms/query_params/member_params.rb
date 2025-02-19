# frozen_string_literal: true

module Lms
  module QueryParams
    module MemberParams
      extend ::Grape::API::Helpers

      params :member_update_params do
        requires :full_name, type: String, allow_blank: false
        requires :email, type: String, allow_blank: false, regexp: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
        requires :gender, type: String, values: %w[male female other], allow_blank: false
        requires :dob, type: Date, allow_blank: false
        requires :father_Name, type: String, allow_blank: false
        requires :mother_name, type: String, allow_blank: false
        optional :profession, type: String, allow_blank: true
        optional :student_class, type: String, allow_blank: true
        optional :student_section, type: String, allow_blank: true
        optional :student_id, type: String, allow_blank: true
        requires :identity_type, type: String, allow_blank: false, values: %w[nid birth_certificate student_id]
        requires :identity_number, type: String, allow_blank: false
        optional :institute_name, type: String, allow_blank: true
        optional :profile_image_file, type: File
        optional :nid_front_image_file, type: File
        optional :nid_back_image_file, type: File
        optional :birth_certificate_image_file, type: File
        optional :student_id_image_file, type: File
        optional :staff_id, type: Integer

      end
    end
  end
end

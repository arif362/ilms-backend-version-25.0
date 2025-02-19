# frozen_string_literal: true

module Admin
  module QueryParams
    module MemberParams
      extend ::Grape::API::Helpers

      params :member_update_params do
        optional :full_name, type: String, allow_blank: false
        optional :phone, type: String, allow_blank: false, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
        optional :email, type: String, allow_blank: false, regexp: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
        optional :gender, type: String, values: %w[male female other], allow_blank: false
        optional :dob, type: Date, allow_blank: false
        optional :library_id, type: Integer, allow_blank: false
        optional :father_Name, type: String, allow_blank: false
        optional :mother_name, type: String, allow_blank: false
        optional :identity_type, type: String, allow_blank: false, values: %w[nid birth_certificate student_id]
        optional :identity_number, type: String, allow_blank: false
        optional :present_address, type: String, allow_blank: false
        optional :permanent_address, type: String, allow_blank: false
        optional :membership_category, type: String, values: %w[general student child], allow_blank: false
        optional :profession, type: String, allow_blank: true
        optional :institute_name, type: String, allow_blank: true
        optional :nid_front_image, type: File
        optional :nid_back_image, type: File
        optional :profile_image, type: File
      end
    end
  end
end

# frozen_string_literal: true

module Lms
  module QueryParams
    module PatronParams
      extend ::Grape::API::Helpers

      params :patron_create_params do
        requires :staff_id, type: Integer, allow_blank: false
        requires :full_name, type: String, allow_blank: false
        requires :phone, type: String, allow_blank: false, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
        optional :email, type: String, allow_blank: false, regexp: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
        requires :gender, type: String, values: User.genders.keys, allow_blank: false
        requires :password, type: String, allow_blank: false
        requires :password_confirmation, type: String, allow_blank: false,
                                         same_as: { value: :password, message: 'not match' }
        requires :dob, type: Date, allow_blank: false
        requires :father_Name, type: String, allow_blank: false
        requires :mother_name, type: String, allow_blank: false
        requires :identity_type, type: String, allow_blank: false, values: RequestDetail.identity_types.keys
        requires :identity_number, type: String, allow_blank: false
        requires :present_address, type: String, allow_blank: false
        optional :present_division_id, type: Integer, allow_blank: false
        optional :present_district_id, type: Integer, allow_blank: false
        optional :present_thana_id, type: Integer, allow_blank: false
        requires :permanent_address, type: String, allow_blank: false
        optional :permanent_division_id, type: Integer, allow_blank: false
        optional :permanent_district_id, type: Integer, allow_blank: false
        optional :permanent_thana_id, type: Integer, allow_blank: false
        requires :present_delivery_area_id, type: Integer, allow_blank: false
        requires :present_delivery_area, type: String, allow_blank: false
        requires :permanent_delivery_area_id, type: Integer, allow_blank: false
        requires :permanent_delivery_area, type: String, allow_blank: false
        optional :delivery_area_id, type: Integer, allow_blank: false
        optional :delivery_area, type: String, allow_blank: false
        optional :card_delivery_type, type: String, values: RequestDetail.card_delivery_types.keys, allow_blank: false
        optional :delivery_division_id, type: Integer, allow_blank: false
        optional :delivery_district_id, type: Integer, allow_blank: false
        optional :delivery_thana_id, type: Integer, allow_blank: false
        requires :membership_category, type: String, values: Member.membership_categories.keys, allow_blank: false
        optional :profession, type: String, allow_blank: false
        optional :institute_name, type: String, allow_blank: false
        optional :institute_address, type: String, allow_blank: false
        optional :student_class, type: String, allow_blank: false
        optional :student_section, type: String, allow_blank: false
        optional :student_id, type: String, allow_blank: false
        optional :profile_image_file, type: File
        optional :nid_front_image_file, type: File
        optional :nid_back_image_file, type: File
        optional :birth_certificate_image_file, type: File
        optional :student_id_image_file, type: File
        optional :verification_certificate_image_file, type: File
      end

      params :patron_present_address_update_params do
        requires :staff_id, type: Integer, allow_blank: false
        requires :member_id, type: Integer, allow_blank: false
        optional :address, type: String, allow_blank: false
        optional :division_id, type: Integer, allow_blank: false
        optional :district_id, type: Integer, allow_blank: false
        optional :thana_id, type: Integer, allow_blank: false
        optional :recipient_name, type: String, allow_blank: false
        optional :recipient_phone, type: String, allow_blank: false
        optional :delivery_area_id, type: Integer, allow_blank: false
        optional :delivery_area, type: String, allow_blank: false
      end
    end
  end
end

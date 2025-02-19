# frozen_string_literal: true

module Lms
  module QueryParams
    module MembershipParams
      extend ::Grape::API::Helpers

      params :membership_update_params do
        requires :staff_id, type: Integer
        requires :request_detail_attributes, type: Hash do
          requires :full_name, type: String, allow_blank: false
          requires :phone, type: String, allow_blank: false
          requires :email, type: String, allow_blank: false
          requires :gender, type: String, values: %w[male female other], allow_blank: false
          requires :dob, type: Date, allow_blank: false
          requires :father_Name, type: String, allow_blank: false
          requires :mother_name, type: String, allow_blank: false
          requires :identity_type, type: String, allow_blank: false, values: %w[nid birth_certificate student_id]
          requires :identity_number, type: String, allow_blank: false
          requires :present_address, type: String, allow_blank: false
          requires :present_division_id, type: Integer, allow_blank: false
          requires :present_district_id, type: Integer, allow_blank: false
          requires :present_thana_id, type: Integer, allow_blank: false
          requires :permanent_address, type: String, allow_blank: false
          requires :permanent_division_id, type: Integer, allow_blank: false
          requires :permanent_district_id, type: Integer, allow_blank: false
          requires :permanent_thana_id, type: Integer, allow_blank: false
          requires :membership_category, type: String, values: %w[general student child], allow_blank: false
          requires :library_id, type: Integer, allow_blank: false
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
          optional :card_delivery_type, type: String, values: RequestDetail.card_delivery_types.keys, allow_blank: false
          optional :delivery_address_type, type: String, values: RequestDetail.delivery_address_types.keys, allow_blank: false
          optional :recipient_name, type: String, allow_blank: false
          optional :recipient_phone, type: String, allow_blank: false
          optional :delivery_address, type: String, allow_blank: false
          optional :delivery_division_id, type: Integer, allow_blank: false
          optional :delivery_district_id, type: Integer, allow_blank: false
          optional :delivery_thana_id, type: Integer, allow_blank: false
          optional :note, type: String, allow_blank: false
        end
      end

      params :membership_upgrade_params do
        requires :staff_id, type: Integer
        requires :phone, type: String, allow_blank: false, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
        requires :identity_type, type: String, allow_blank: false, values: %w[nid birth_certificate student_id]
        requires :identity_number, type: String, allow_blank: false
        requires :membership_category, type: String, values: Member.membership_categories.keys, allow_blank: false
        requires :card_delivery_type, type: String, values: RequestDetail.card_delivery_types.keys, allow_blank: false
        requires :is_self_recipient, type: Boolean, allow_blank: false
        optional :profession, type: String, allow_blank: false
        optional :institute_name, type: String, allow_blank: false
        optional :institute_address, type: String, allow_blank: false
        optional :student_class, type: String, allow_blank: false
        optional :student_section, type: String, allow_blank: false
        optional :student_id, type: String, allow_blank: false
        optional :nid_front_image_file, type: File
        optional :nid_back_image_file, type: File
        optional :birth_certificate_image_file, type: File
        optional :student_id_image_file, type: File
        optional :verification_certificate_image_file, type: File
        optional :delivery_address_type, type: String, values: RequestDetail.delivery_address_types.keys, allow_blank: false
        optional :recipient_name, type: String, allow_blank: false
        optional :recipient_phone, type: String, allow_blank: false
        optional :delivery_address, type: String, allow_blank: false
        optional :delivery_division_id, type: Integer, allow_blank: false
        optional :delivery_district_id, type: Integer, allow_blank: false
        optional :delivery_thana_id, type: Integer, allow_blank: false
        optional :note, type: String, allow_blank: false
      end
    end
  end
end

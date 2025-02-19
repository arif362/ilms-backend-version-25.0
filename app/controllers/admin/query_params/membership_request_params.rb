# frozen_string_literal: true

module Admin
  module QueryParams
    module MembershipRequestParams
      extend ::Grape::API::Helpers

      params :membership_request_acc_update_params do
        optional :full_name, type: String, allow_blank: false
        optional :phone, type: String, allow_blank: false
        optional :email, type: String, allow_blank: false
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
      end
    end
  end
end

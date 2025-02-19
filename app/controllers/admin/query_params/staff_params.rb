# frozen_string_literal: true

module Admin
  module QueryParams
    module StaffParams
      extend ::Grape::API::Helpers
      params :staff_create_params do
        requires :name, type: String, allow_blank: false
        requires :staff_type, type: String, allow_blank: false, values: %w[admin library]
        requires :email, type: String, allow_blank: false
        requires :phone, type: String, allow_blank: false
        requires :password, type: String, allow_blank: false
        requires :password_confirmation, type: String, allow_blank: false
        requires :designation_id, type: Integer, allow_blank: false
        requires :gender, type: String, values: Staff.genders.keys, allow_blank: false
        optional :is_library_head, type: Boolean, default: false, allow_blank: false
        optional :role_id, type: Integer, allow_blank: false
        optional :library_id, type: Integer, allow_blank: false
        requires :dob, type: DateTime, allow_blank: false
        requires :joining_date, type: DateTime, allow_blank: false
        requires :joining_library_id, type: Integer, allow_blank: false
        requires :sanctioned_post, type: String, allow_blank: false
        requires :staff_class, type: String, allow_blank: false
        requires :staff_grade, type: String, allow_blank: false
        optional :avatar_image, type: File, allow_blank: false
        optional :authorized_signature_image, type: File, allow_blank: false
      end

      params :staff_update_params do
        requires :name, type: String, allow_blank: false
        requires :staff_type, type: String, allow_blank: false, values: %w[admin library]
        requires :email, type: String, allow_blank: false
        requires :phone, type: String, allow_blank: false
        requires :designation_id, type: Integer, allow_blank: false
        optional :gender, type: String, values: Staff.genders.keys, allow_blank: false
        optional :role_id, type: Integer, allow_blank: false
        optional :is_library_head, type: Boolean, default: false, allow_blank: false
        optional :library_id, type: Integer, allow_blank: false
        requires :dob, type: DateTime, allow_blank: false
        requires :joining_date, type: DateTime, allow_blank: false
        requires :joining_library_id, type: Integer, allow_blank: false
        optional :sanctioned_post, type: String, allow_blank: false
        requires :staff_class, type: String, allow_blank: false
        requires :staff_grade, type: String, allow_blank: false
        optional :is_active, type: Boolean, allow_blank: false
        optional :avatar_image, type: File, allow_blank: false
        optional :authorized_signature_image, type: File, allow_blank: false
        optional :retired_date, type: DateTime, allow_blank: false
      end

      params :staff_type_params do
        requires :staff_type, type: String, allow_blank: false, values: %w[admin library]
        optional :library_id, type: Integer, allow_blank: false
        optional :role_id, type: Integer, allow_blank: false
      end

    end
  end
end

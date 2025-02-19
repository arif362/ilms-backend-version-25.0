# frozen_string_literal: true

module PublicLibrary
  module QueryParams
    module UserParams
      extend ::Grape::API::Helpers
      params :user_create_params do
        requires :full_name, type: String, allow_blank: false
        optional :email, type: String
        requires :phone, type: String, allow_blank: false, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
        requires :dob, type: DateTime, allow_blank: false
        requires :gender, type: String, values: %w[male female other], allow_blank: false
      end

      params :user_update_params do
        requires :full_name, type: String, allow_blank: false
        optional :email, type: String
        requires :dob, type: DateTime, allow_blank: false
        requires :gender, type: String, allow_blank: false, values: User.genders.keys
      end

      params :user_photo_update_params do
        requires :image_file, type: File
      end

      params :otp_verify_params do
        requires :phone, type: String, allow_blank: false, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
        requires :otp, type: String, allow_blank: false
      end

      params :password_params do
        requires :tmp_id, type: Integer, allow_blank: false
        requires :otp, type: String, allow_blank: false
        requires :password, type: String, allow_blank: false
        requires :password_confirmation, type: String, allow_blank: false,
                                         same_as: { value: :password, message: 'not match' }
      end

      params :reset_password_params do
        optional :phone, type: String, allow_blank: false, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
        requires :otp, type: String, allow_blank: false
        requires :password, type: String, allow_blank: false
        requires :password_confirmation, type: String, allow_blank: false,
                                         same_as: { value: :password, message: 'not match' }
      end

      params :change_password_params do
        requires :current_password, type: String, allow_blank: false
        requires :password, type: String, allow_blank: false
        requires :password_confirmation, type: String, allow_blank: false,
                                         same_as: { value: :password, message: 'not match' }
      end

      params :change_phone_params do
        requires :phone, type: String, allow_blank: false, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
        requires :current_password, type: String, allow_blank: false
      end
    end
  end
end

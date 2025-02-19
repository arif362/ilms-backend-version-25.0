# frozen_string_literal: true

module Lms
  module QueryParams
    module UserParams
      extend ::Grape::API::Helpers
      params :validate_params do
        requires :is_member, type: Boolean, values: [true, false], allow_blank: false
        optional :phone, type: String, allow_blank: false, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
        optional :password, type: String, allow_blank: false
        optional :library_card_number, type: String, allow_blank: false
      end

      params :user_register_params do
        requires :full_name, type: String, allow_blank: false
        optional :email, type: String, allow_blank: false
        requires :phone, type: String, allow_blank: false, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
        requires :dob, type: DateTime, allow_blank: false
      end

      params :user_otp_resend_params do
        requires :phone, type: String, allow_blank: false, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
      end

      params :otp_verify_params do
        requires :otp, type: String, allow_blank: false
        requires :phone, type: String, allow_blank: false, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
      end

      params :password_params do
        requires :tmp_id, type: Integer, allow_blank: false
        requires :password, type: String, allow_blank: false
      end
    end
  end
end

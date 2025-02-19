# frozen_string_literal: true

module Lms
  module QueryParams
    module PhoneChangeRequestParams
      extend ::Grape::API::Helpers

      params :change_phone_params do
        requires :staff_id, type: Integer, allow_blank: false
        requires :member_id, type: Integer, allow_blank: false
        requires :otp, type: String, allow_blank: false
      end

      params :change_phone_resend_otp_params do
        requires :staff_id, type: Integer, allow_blank: false
        requires :member_id, type: Integer, allow_blank: false
        requires :phone, type: String, allow_blank: false, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
      end
    end
  end
end

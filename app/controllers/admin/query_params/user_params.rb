# frozen_string_literal: true

module Admin
  module QueryParams
    module UserParams
      extend ::Grape::API::Helpers

      params :user_update_params do
        requires :full_name, type: String, allow_blank: false
        requires :phone, type: String, allow_blank: false, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
        requires :email, type: String, allow_blank: false, regexp: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
        requires :gender, type: String, values: %w[male female other], allow_blank: false
        requires :dob, type: Date, allow_blank: false
      end
    end
  end
end

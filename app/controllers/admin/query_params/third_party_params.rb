# frozen_string_literal: true

module Admin
  module QueryParams
    module ThirdPartyParams
      extend ::Grape::API::Helpers
      params :third_party_create_params do
        requires :name, type: String, allow_blank: false
        requires :company, type: String, allow_blank: false
        requires :email, type: String, allow_blank: false
        requires :phone, type: String, allow_blank: false, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
        requires :password, type: String, allow_blank: false
        requires :password_confirmation, type: String, allow_blank: false

      end

      params :third_party_update_params do
        requires :name, type: String, allow_blank: false
        requires :company, type: String, allow_blank: false
        requires :email, type: String, allow_blank: false
        requires :phone, type: String, allow_blank: false, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
      end
    end
  end
end

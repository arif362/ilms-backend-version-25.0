# frozen_string_literal: true

module Lms
  module QueryParams
    module GuestParams
      extend ::Grape::API::Helpers
      params :guest_create_params do
        requires :name, type: String, allow_blank: false
        requires :phone, type: String, allow_blank: false
        optional :email, type: String, allow_blank: false
        optional :gender, type: String, values: %w[male female other], allow_blank: false
        optional :dob, type: Date, allow_blank: false
      end
    end
  end
end

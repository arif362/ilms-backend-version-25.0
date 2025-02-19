# frozen_string_literal: true

module Lms
  module QueryParams
    module StaffParams
      extend ::Grape::API::Helpers

      params :staff_validate_params do
        requires :email, type: String
        requires :password, type: String
      end
    end
  end
end

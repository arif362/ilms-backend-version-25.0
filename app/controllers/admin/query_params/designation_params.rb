# frozen_string_literal: true

module Admin
  module QueryParams
    module DesignationParams
      extend ::Grape::API::Helpers
      params :designation_create_params do
        requires :title, type: String, allow_blank: false
      end

      params :designation_update_params do
        requires :title, type: String, allow_blank: false
      end
    end
  end
end

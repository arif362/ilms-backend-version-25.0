# frozen_string_literal: true

module Admin
  module QueryParams
    module DivisionParams
      extend ::Grape::API::Helpers

      params :division_create_params do
        requires :name, allow_blank: false, type: String
        requires :bn_name, allow_blank: false, type: String
      end

      params :division_update_params do
        requires :name, allow_blank: false, type: String
        requires :bn_name, allow_blank: false, type: String
      end
    end
  end
end

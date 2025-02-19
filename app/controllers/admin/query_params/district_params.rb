# frozen_string_literal: true

module Admin
  module QueryParams
    module DistrictParams
      extend ::Grape::API::Helpers

      params :district_create_params do
        requires :name, allow_blank: false, type: String
        requires :bn_name, allow_blank: false, type: String
        requires :division_id, allow_blank: false, type: Integer
      end

      params :district_update_params do
        requires :name, allow_blank: false, type: String
        requires :bn_name, allow_blank: false, type: String
        requires :division_id, allow_blank: false, type: Integer
      end
    end
  end
end

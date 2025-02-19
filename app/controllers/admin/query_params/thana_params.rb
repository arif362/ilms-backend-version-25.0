# frozen_string_literal: true

module Admin
  module QueryParams
    module ThanaParams
      extend ::Grape::API::Helpers

      params :thana_create_params do
        requires :name, allow_blank: false, type: String
        requires :bn_name, allow_blank: false, type: String
        requires :district_id, allow_blank: false, type: Integer
      end

      params :thana_update_params do
        requires :name, allow_blank: false, type: String
        requires :bn_name, allow_blank: false, type: String
        requires :district_id, allow_blank: false, type: Integer
      end
    end
  end
end

# frozen_string_literal: true

module Lms
  module QueryParams
    module ItemTypeParams
      extend ::Grape::API::Helpers
      params :item_type_create_params do
        requires :staff_id, type: Integer
        requires :title, type: String, allow_blank: false
        requires :option_value, type: String, allow_blank: false
      end

      params :item_type_update_params do
        requires :staff_id, type: Integer
        requires :title, type: String, allow_blank: false
        # requires :option_value, type: String, allow_blank: false
      end

      params :item_type_delete_params do
        requires :staff_id, type: Integer
      end
    end
  end
end

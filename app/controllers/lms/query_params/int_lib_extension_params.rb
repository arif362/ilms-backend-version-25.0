# frozen_string_literal: true

module Lms
  module QueryParams
    module IntLibExtensionParams
      extend ::Grape::API::Helpers

      params :int_lib_extension_create_params do
        requires :staff_id, type: Integer
        requires :book_transfer_order_id, type: Integer
        requires :extend_end_date, type: DateTime
      end

      params :int_lib_extension_update_params do
        requires :staff_id, type: Integer
        requires :book_transfer_order_id, type: Integer
        requires :status, type: String, values: IntLibExtension.statuses.keys - ['pending']
      end
    end
  end
end

# frozen_string_literal: true

module Lms
  module QueryParams
    module ReturnOrderParams
      extend ::Grape::API::Helpers

      params :return_order_create_params do
        requires :staff_id, type: Integer
        requires :barcodes, type: Array[String]
        optional :note, type: String
      end

      params :return_order_update_params do
        requires :staff_id, type: Integer
      end
    end
  end
end

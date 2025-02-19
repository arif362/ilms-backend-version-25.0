# frozen_string_literal: true

module Admin
  module QueryParams
    module PaymentParams
      extend ::Grape::API::Helpers
      params :payments_search_params do
        optional :code, type: String
        optional :status, type: String, values: Payment.statuses.keys
        optional :payment_type, type: String, values: Payment.payment_types.keys
        optional :trx_id, type: String
        optional :invoice_id, type: Integer
        optional :start_date, type: DateTime
        optional :end_date, type: DateTime
        optional :end_date, type: DateTime
        optional :phone, type: String
        optional :purpose, type: String, values: Payment.purposes.keys
      end
    end
  end
end

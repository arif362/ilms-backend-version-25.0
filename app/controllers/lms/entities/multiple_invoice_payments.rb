# frozen_string_literal: true

module Lms
  module Entities
    class MultipleInvoicePayments < Grape::Entity
      include Lms::Helpers::ImageHelpers

      expose :id
      expose :payment_type, as: :payment_method
      expose :created_at, as: :payment_date
      expose :received_by
      expose :invoices

      def invoices
        Lms::Entities::PatronFines.represent(object.invoices)
      end

      def received_by
        Lms::Entities::Staffs.represent(object.created_by)
      end
    end
  end
end

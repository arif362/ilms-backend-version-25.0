# frozen_string_literal: true
module PublicLibrary
  module Entities
    class UnpaidInvoices < Grape::Entity
      expose :id
      expose :invoice_status
      expose :invoice_amount
      expose :reason

      def reason
        object.invoiceable.class.to_s.titleize
      end
    end
  end
end

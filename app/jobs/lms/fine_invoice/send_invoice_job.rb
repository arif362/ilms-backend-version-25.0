# frozen_string_literal: true

module Lms
  module FineInvoice
    class SendInvoiceJob < ApplicationJob
      queue_as :default
      def perform(invoice)
        Lms::FinePayment::SendInvoice.call(invoice:)
      end
    end
  end
end

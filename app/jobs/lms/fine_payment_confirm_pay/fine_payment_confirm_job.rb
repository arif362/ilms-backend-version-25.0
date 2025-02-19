# frozen_string_literal: true

module Lms
  module FinePaymentConfirmPay
    class FinePaymentConfirmJob < ApplicationJob
      queue_as :default
      def perform(invoice)
        Lms::FinePayment::FinePaymentConfirm.call(invoice:)
      end
    end
  end
end

# frozen_string_literal: true

module PublicLibrary::Helpers

  module PaymentHelper
    extend Grape::API::Helpers
    def invoice(invoice_type)
      invoice ||= @current_user.send(invoice_type.to_sym).pending.find_by(id: params[:invoice_id])
      error!('invoice request not found', HTTP_CODE[:NOT_FOUND]) unless invoice.present?
      @invoice
    end

    def cancel_payment
      payment.update!(status: Payment.statuses[:cancelled])
    end
  end
end

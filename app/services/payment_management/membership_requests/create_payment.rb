module PaymentManagement
  module MembershipRequests
    class CreatePayment
      include Interactor

      delegate :invoice, :payment_type, :status, :user, :transaction_type, :payment, :purpose, to: :context

      def call
        payment = Payment.new payment_attributes
        payment.invoices_payments.build(invoice:)
        context.fail!(error: payment.errors.full_messages.to_sentence) unless payment.save!
        context.payment = payment
      end

      private

      def payment_attributes
        {
          invoice_id: invoice.id,
          amount: invoice.invoice_amount,
          payment_type:,
          status:,
          user:,
          created_by: user,
          purpose:,
          transaction_type: invoice.security_money_withdraw? ? 'out_going' : 'in_coming'
        }
      end
    end
  end
end

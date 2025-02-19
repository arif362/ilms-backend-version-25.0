module PaymentManagement
  module Fine
    class CreatePayment
      include Interactor

      delegate :invoice_ids, :payment_type, :status, :user, :created_by, :transaction_type, :payment, :purpose, to: :context

      def call
        context.payment = Payment.new payment_attributes
        context.fail!(error: payment.errors.full_messages.to_sentence) unless payment.save!
        add_invoices_to_payment(payment)
      end

      private

      def add_invoices_to_payment(payment)
        invoice_ids.each do |invoice|
          invoices_payment = payment.invoices_payments.new(invoice_id: invoice)
          context.fail!(error: invoices_payment.errors.full_messages.to_sentence) unless invoices_payment.save!
        end
      end

      def payment_attributes
        {
          amount: fetch_invoices_amount,
          payment_type:,
          status:,
          user:,
          created_by:,
          purpose:,
          transaction_type: 'in_coming'
        }
      end

      def fetch_invoices_amount
        amount = 0
        invoice_ids.each do |invoice_id|
          invoice = Invoice.fine.find_by(id: invoice_id)
          context.fail!(error: "Invoice ID #{invoice_id} not found") unless invoice.present?
          amount += invoice.invoice_amount
        end
        amount
      end

    end
  end
end

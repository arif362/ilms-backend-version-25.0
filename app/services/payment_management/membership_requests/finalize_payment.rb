module PaymentManagement
  module MembershipRequests
    class FinalizePayment
      include Interactor

      delegate :payment, :status, :library_staff, to: :context

      def call
        return if payment.update(status:, updated_by: library_staff)

        context.fail!(error: payment.errors.full_messages.to_sentence)

      end
    end
  end
end

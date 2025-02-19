# frozen_string_literal: true

module AccountDeletionManagement
  class ValidateAccountDeletion
    include Interactor

    delegate :user, to: :context

    def call
      check_items_on_hand
      check_security_moneys
      check_fines
    end

    private

    def check_items_on_hand
      items_on_hand = user.items_on_hand
      context.fail!(error: 'Please cancel order/return borrowed books') if items_on_hand.positive?
    end

    def check_security_moneys
      security_moneys = user.security_moneys.available
      return if security_moneys.blank?

      context.fail!(error: 'Please collect your security money before deleting the account')
    end

    def check_fines
      fine_invoices = user.invoices.fine.where.not(invoice_status: :paid)
      current_circulations = user.member&.circulations&.where('circulation_status_id = ? AND return_at < ?',
                                                              CirculationStatus.get_status(:borrowed).id,
                                                              Date.today.end_of_day)
      context.fail!(error: 'Please pay your fines') unless fine_invoices.blank? || current_circulations.blank?
    end
  end
end

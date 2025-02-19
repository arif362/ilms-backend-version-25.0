module PublicLibrary
  module Entities
    class SecurityMoneyRequestDetails < Grape::Entity
      expose :id
      expose :user
      expose :amount
      expose :status
      expose :payment_method
      expose :note
      expose :created_at
      expose :rejected_reasons
      expose :is_reapply_able

      def user
        object.user.as_json(only: %i[id full_name phone])
      end

      def rejected_reasons
        reasons = []
        if object&.user&.invoices&.pending&.where&.not(invoice_type: :security_money_withdraw).present?
          reasons << 'You have fine and pending invoices'
        end
        reasons << 'Security money not available' unless object&.user&.security_moneys&.available
        reasons << 'Security money has been seized' if object&.user&.security_moneys&.seized.present?
        if object&.user&.member&.circulations&.where(circulation_status: CirculationStatus.get_status('borrowed')).present?
          reasons << 'You have not returned the borrowed books yet'
        end
        reasons
      end

      def is_reapply_able
        rejected_reasons.empty?
      end
    end
  end
end

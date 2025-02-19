# frozen_string_literal: true

module SecurityWithdrawalManager
  class SecurityWithdrawalValidator
    include Interactor
    include Constants

    delegate :user, :is_validator, to: :context

    def call
      check_withdrawal_eligibility
    end

    private

    def check_withdrawal_eligibility
      errors = []
      if user.security_money_requests&.pending.present?
        context.fail!(error: 'Security money already requested') unless is_validator
        errors << { status_code: HTTP_CUSTOM_CODE[:ALREADY_REQUESTED], message: 'Security money already requested' }
      end
      if user&.invoices&.fine&.pending.present?
        context.fail!(error: 'You have fine and pending invoices') unless is_validator
        errors << { status_code: HTTP_CUSTOM_CODE[:PENDING_INVOICE], message: 'You have pending invoices' }
      end
      if (Time.current.to_date.year - user.member.activated_at.to_date.year) < ENV['MATURED_SECURITY_MONEY_YEAR'].to_i
        unless is_validator
          context.fail!(error: 'After one year of your membership duration, you are eligible to withdraw security money')
        end
        errors << { status_code: HTTP_CUSTOM_CODE[:IMMATURE_MEMBERSHIP],
                    message: 'After one year of your membership duration, you are eligible to withdraw security money' }
      end
      circulations = user.member.circulations.where(circulation_status: CirculationStatus.get_status('borrowed'))
      if circulations.present?
        context.fail!(error: 'Please return your borrowed books first') unless is_validator
        errors << { status_code: HTTP_CUSTOM_CODE[:BORROWED_BOOK_EXIST],
                    message: 'Please return your borrowed books first' }
      end
      context.fail!(error: errors) unless errors.empty? && is_validator
    end
  end
end

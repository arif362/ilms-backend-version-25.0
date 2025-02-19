class SecurityMoneyRequestPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :SECURITY_MONEY_REQUEST)
  end
end

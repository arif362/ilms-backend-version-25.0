class SecurityMoneyPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :SECURITY_MONEY)
  end
end

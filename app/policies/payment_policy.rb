class PaymentPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :PAYMENT)
  end
end

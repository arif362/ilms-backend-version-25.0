class OrderPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :ORDER)
  end
end

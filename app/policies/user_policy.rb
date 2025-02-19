class UserPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :USER)
  end
end
class RolePolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :ROLE)
  end
end

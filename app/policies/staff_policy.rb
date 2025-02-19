class StaffPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :ADMIN)
  end
end

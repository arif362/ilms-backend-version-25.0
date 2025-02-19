class DivisionPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :DIVISION)
  end
end

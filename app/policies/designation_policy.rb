class DesignationPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :DESIGNATION)
  end
end

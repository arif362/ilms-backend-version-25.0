class DistrictPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :DISTRICT)
  end
end

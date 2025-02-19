class DistributionPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :DISTRIBUTION)
  end
end

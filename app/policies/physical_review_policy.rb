class PhysicalReviewPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :PHYSICAL_REVIEW)
  end
end
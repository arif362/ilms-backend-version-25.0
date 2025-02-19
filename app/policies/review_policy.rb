class ReviewPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :REVIEW)
  end

  def accept_reject?
    permission?('review-accept-reject')
  end
end

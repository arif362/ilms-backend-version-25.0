class MembershipRequestPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :MEMBERSHIP_REQUEST)
  end

  def accept_reject?
    permission?('membership-request-accept-reject')
  end
end
class MemberPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :MEMBER)
  end
end
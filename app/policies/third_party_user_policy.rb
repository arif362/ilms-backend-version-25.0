class ThirdPartyUserPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :THIRD_PARTY_USER)
  end
end

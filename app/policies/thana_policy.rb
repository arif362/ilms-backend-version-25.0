class ThanaPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :THANA)
  end
end

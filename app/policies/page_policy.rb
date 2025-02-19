class PagePolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :PAGE)
  end
end

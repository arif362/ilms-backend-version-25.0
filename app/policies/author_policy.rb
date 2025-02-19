class AuthorPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :AUTHOR)
  end
end

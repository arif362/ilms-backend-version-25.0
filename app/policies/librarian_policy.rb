class LibrarianPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :LIBRARIAN)
  end
end

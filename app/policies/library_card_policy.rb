class LibraryCardPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :LIBRARY_CARD_REQUEST)
  end
end
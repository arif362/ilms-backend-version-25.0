class LibraryLocationPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :LIBRARY_LOCATION)
  end
end
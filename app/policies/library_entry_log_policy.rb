class LibraryEntryLogPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :LIBRARY_ENTRY_LOG)
  end
end
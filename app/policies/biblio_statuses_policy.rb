class BiblioStatusesPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :BIBLIO_STATUS)
  end
end
class BiblioEditionPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :BIBLIO_EDITION)
  end
end
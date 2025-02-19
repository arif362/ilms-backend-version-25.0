class BiblioPublicationPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :BIBLIO_PUBLICATION)
  end
end
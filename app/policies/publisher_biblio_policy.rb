class PublisherBiblioPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :PUBLISHER_BIBLIO)
  end
end

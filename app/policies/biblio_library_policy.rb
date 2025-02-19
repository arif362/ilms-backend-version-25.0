# frozen_string_literal: true

class BiblioLibraryPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :BIBLIO_LIBRARY)
  end
end

# frozen_string_literal: true

class RebindBiblioPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :REBIND_BIBLIO)
  end
end

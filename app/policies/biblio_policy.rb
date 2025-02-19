# frozen_string_literal: true

class BiblioPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :BIBLIO)
  end
end

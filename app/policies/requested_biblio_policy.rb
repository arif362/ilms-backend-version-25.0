# frozen_string_literal: true

class RequestedBiblioPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :REQUESTED_BIBLIO)
  end
end

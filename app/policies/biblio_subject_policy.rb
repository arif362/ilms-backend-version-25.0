# frozen_string_literal: true

class BiblioSubjectPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :BIBLIO_SUBJECT)
  end
end

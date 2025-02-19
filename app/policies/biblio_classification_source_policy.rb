# frozen_string_literal: true
class BiblioClassificationSourcePolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :BIBLIO_CLASSIFICATION_SOURCE)
  end
end
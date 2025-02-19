# frozen_string_literal: true

class FailedSearchPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :FAILED_SEARCH)
  end
end

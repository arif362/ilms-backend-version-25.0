# frozen_string_literal: true

class KeyPersonPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :KEY_PERSON)
  end
end

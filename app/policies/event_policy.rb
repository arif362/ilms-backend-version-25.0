# frozen_string_literal: true

class EventPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :EVENT)
  end
end

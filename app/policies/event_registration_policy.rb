# frozen_string_literal: true

class EventRegistrationPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :EVENT_REGISTRATION)
  end
end

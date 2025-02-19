# frozen_string_literal: true

class EventLibraryPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :EVENT_LIBRARY)
  end
end

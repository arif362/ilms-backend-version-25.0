# frozen_string_literal: true

class CirculationPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :CIRCULATION)
  end
end

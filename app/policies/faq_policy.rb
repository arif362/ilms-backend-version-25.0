# frozen_string_literal: true

class FaqPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :FAQ)
  end
end

# frozen_string_literal: true

class ComplainPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :COMPLAIN)
  end
end

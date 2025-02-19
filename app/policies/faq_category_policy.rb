# frozen_string_literal: true

class FaqCategoryPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :FAQ_CATEGORY)
  end
end

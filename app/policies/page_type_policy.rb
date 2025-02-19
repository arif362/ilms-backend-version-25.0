# frozen_string_literal: true

class PageTypePolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :PAGE_TYPE)
  end
end

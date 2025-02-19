# frozen_string_literal: true

class DocumentCategoryPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :DOCUMENT_CATEGORY)
  end
end

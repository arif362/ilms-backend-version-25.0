# frozen_string_literal: true

class DocumentPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :DOCUMENT)
  end
end

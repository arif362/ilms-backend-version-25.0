# frozen_string_literal: true

class AccountDeletionRequestPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :ACCOUNT_DELETION_REQUEST)
  end
end

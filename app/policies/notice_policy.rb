# frozen_string_literal: true

class NoticePolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :NOTICE)
  end
end

# frozen_string_literal: true

class BannerPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :BANNER)
  end
end

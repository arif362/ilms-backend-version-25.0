# frozen_string_literal: true

class HomepageSliderPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :HOMEPAGE_SLIDER)
  end
end

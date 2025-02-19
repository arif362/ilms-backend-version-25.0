# frozen_string_literal: true

class IlsReportPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :ILS_REPORT)
  end
end

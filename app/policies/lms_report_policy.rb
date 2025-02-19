class LmsReportPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :LMS_REPORT)
  end
end

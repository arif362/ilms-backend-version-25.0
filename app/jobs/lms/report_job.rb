# frozen_string_literal: true

module Lms
  class ReportJob < ApplicationJob
    queue_as :default

    def perform(ils_report_current)
      Lms::Reports.call(ils_report_current:)
    end
  end
end

# frozen_string_literal: true

module Admin
  class IlsReports < Admin::Base
    resources :ils_reports do
      include Admin::Helpers::AuthorizationHelpers

      desc 'Ils report details'
      params do
        optional :year_month, type: String, regexp: /\A\d{4}-(0[1-9]|1[0-2])\z/
      end
      get do
        ils_report = IlsReport.last
        if params[:year_month].present?
          year_month = params[:year_month]
          year, month = year_month.split('-').map(&:to_i)
          first_date_of_month = Date.new(year, month, 1)
          error!('Invalid Year Month', HTTP_CODE[:NOT_FOUND]) if first_date_of_month > DateTime.now
          ils_report = IlsReport.find_by(month: first_date_of_month)
        end
        error!('Ils ils_report not found', HTTP_CODE[:NOT_FOUND]) unless ils_report.present?
        authorize ils_report, :read?
        Admin::Entities::YearlyReportDetails.represent(ils_report)
      end
    end
  end
end

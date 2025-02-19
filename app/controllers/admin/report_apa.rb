# frozen_string_literal: true

module Admin
  class ReportApa < Admin::Base
    resources :report_apa do
      include Admin::Helpers::AuthorizationHelpers

      desc 'apa report list'
      params do
        optional :gender, type: String, values: %w[male female child], default: 'male'
        optional :quarter_name, type: Integer, values: [1, 2, 3, 4], default: 3
        requires :year, type: String, regexp: /\d{4}/, allow_blank: false
        optional :types, type: String, values: Library.library_types.keys
      end
      get do
        months = month_number(params[:quarter_name])
        apa_reports = LmsReport.select(:id, :library_id, :month, "book_reader_#{params[:gender].downcase}".to_sym, "paper_magazine_reader_#{params[:gender].downcase}".to_sym).joins(:library).where("MONTH(lms_reports.month) IN (?) AND YEAR(lms_reports.month) = ?", months, params[:year]).includes(:library)
        apa_reports = apa_reports.where(libraries: { library_type: params[:types] }) if params[:types].present?

        Admin::Entities::ApaReport.represent(apa_reports, gender: params[:gender])
      end
    end
  end
end

def month_number(value)
  case value
  when 1
    (7..9).to_a
  when 2
    (10..12).to_a
  when 3
    (1..3).to_a
  when 4
    (4..6).to_a
  else
    []
  end
end


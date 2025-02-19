class LmsReport < ApplicationRecord

  audited
  serialize :papers_bangla, Array
  serialize :papers_english, Array
  serialize :magazine_bangla, Array
  serialize :magazine_english, Array
  serialize :development_project, Array
  serialize :bind_paper_bangla, JSON
  serialize :bind_paper_english, JSON
  serialize :bind_magazine_bangla, JSON
  serialize :bind_magazine_english, JSON
  serialize :edited_fields_default_values, JSON
  serialize :event_participants, JSON
  serialize :event_winners, JSON
  serialize :staff_ids, Array
  serialize :present_main_staff_ids, Array

  belongs_to :updated_by, polymorphic: true, optional: true
  belongs_to :created_by, polymorphic: true, optional: true
  belongs_to :library
  has_many :ils_lms_reports
  has_many :ils_reports, through: :ils_lms_reports

  after_commit do
    ils_report_current = IlsReport.find_or_create_by(month: month.beginning_of_month)
    IlsLmsReport.find_or_create_by(lms_report_id: id, ils_report_id: ils_report_current.id)
    Lms::ReportJob.perform_later(ils_report_current)
  end

end

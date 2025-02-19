class IlsReport < ApplicationRecord

  serialize :papers_bangla, Array
  serialize :papers_english, Array
  serialize :magazine_bangla, Array
  serialize :magazine_english, Array
  has_many :ils_lms_reports
  has_many :lms_reports, through: :ils_lms_reports
end

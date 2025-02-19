class LibraryWorkingDay < ApplicationRecord
  belongs_to :library, optional: true
  belongs_to :staff, foreign_key: :created_by_id, optional: true
  belongs_to :staff, foreign_key: :updated_by_id, optional: true

  validates :week_days, presence: true
  validates_presence_of :start_time, :end_time, unless: -> { is_holiday }
  validates :end_time,
            comparison: { greater_than_or_equal_to: :start_time },
            if: -> { end_time_changed? && !is_holiday }

  enum week_days: { thursday: 0, friday: 1, saturday: 2, sunday: 3, monday: 4, tuesday: 5, wednesday: 6 }
end

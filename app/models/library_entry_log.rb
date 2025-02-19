class LibraryEntryLog < ApplicationRecord
  SERVICE_NAMES = %w[read_books borrow_books read_newspapers journal use_internet exam_or_job_preparation reference_service research].freeze
  serialize :services, Array

  belongs_to :entryable, polymorphic: true
  belongs_to :library
  belongs_to :thana, optional: true
  belongs_to :district, optional: true

  enum gender: { male: 0, female: 1, other: 2 }

  before_create :assign_join_attrs
  after_create :count_increase

  private

  def assign_join_attrs
    self.name = entryable&.registered_name
    self.email = entryable&.email
    self.phone = entryable&.phone
    self.gender = entryable&.gender
    self.age = age_calculator
    self.thana_id = library&.thana_id
    self.district_id = library&.thana&.district_id
  end

  def count_increase
    library = Library.find_by(id: library_id)
    case entryable_type
    when 'User'
      library.increment!(:total_user_count)
    when 'Member'
      library.increment!(:total_member_count)
    when 'Guest'
      library.increment!(:total_guest_count)
    end

  end

  def age_calculator
    (Date.today.year - (entryable&.dob&.to_date || Date.today).year)
  end
end

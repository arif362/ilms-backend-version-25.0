# frozen_string_literal: true

class Author < ApplicationRecord
  audited
  has_many :author_biblios, dependent: :restrict_with_exception
  has_many :biblios, through: :author_biblios
  has_many :user_suggestions, dependent: :restrict_with_exception

  validates :first_name, :bn_first_name, presence: true
  validates :dob, length: { is: 4 }, allow_blank: true
  validates :dod, length: { is: 4 },
                  allow_blank: true,
                  comparison: { greater_than: :dob, message: 'must be greater than dob' }
  # validate :validate_uniqueness
  scope :not_deleted, -> { where(is_deleted: false) }

  before_save :set_audit_user

  after_commit on: :create do
    Lms::AuthorJob.perform_later(self, 'created')
  end

  after_commit on: :update do
    Lms::AuthorJob.perform_later(self, 'updated')
  end
  # before_save :record_type


  def full_name
    [first_name, middle_name, last_name].compact.map(&:strip).join(' ')
  end

  def bn_full_name
    [bn_first_name, bn_middle_name, bn_last_name].compact.map(&:strip).join(' ')
  end

  def validate_uniqueness
    author = Author.not_deleted.find_by('first_name = ? and (middle_name = ?  OR middle_name IS NULL)
                                             and (last_name = ?  or last_name IS NULL) and dob = ?',
                                        first_name, middle_name, last_name, dob)
    errors.add :name_and_dob, 'must be unique' if author.present?
  end

  def set_audit_user
    Audited.store[:audited_user] = Staff.find_by(id: created_by_id)
    Audited.store[:audited_user] = Staff.find_by(id: updated_by_id) if persisted?
  end
end

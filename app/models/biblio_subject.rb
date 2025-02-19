# frozen_string_literal: true

class BiblioSubject < ApplicationRecord
  audited
  has_many :biblio_subject_biblios
  has_many :biblios, through: :biblio_subject_biblios
  has_many :user_suggestions, dependent: :restrict_with_exception

  validates :personal_name, :bn_personal_name, presence: true
  validates_uniqueness_of :personal_name, :bn_personal_name, conditions: -> { where(is_deleted: false) }
  validates_uniqueness_of :slug, conditions: -> { where(is_deleted: false) }

  scope :not_deleted, -> { where(is_deleted: false) }

  before_create :set_slug
  before_save :set_audit_user

  after_commit on: :create do
    Lms::SubjectJob.perform_later(self, 'created')
  end

  after_commit on: :update do
    Lms::SubjectJob.perform_later(self, 'updated')
  end

  private

  def set_slug
    self.slug = personal_name.to_s.parameterize
  end

  def set_audit_user
    Audited.store[:audited_user] = Staff.find_by(id: created_by_id)
    Audited.store[:audited_user] = Staff.find_by(id: updated_by_id) if persisted?
  end
end

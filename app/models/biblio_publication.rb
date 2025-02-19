# frozen_string_literal: true

class BiblioPublication < ApplicationRecord
  audited
  has_many :biblios, dependent: :restrict_with_exception

  validates :title, :bn_title, presence: true
  validates_uniqueness_of :title, :bn_title, conditions: -> { where(is_deleted: false) }

  scope :not_deleted, -> { where(is_deleted: false) }

  before_save :set_audit_user

  after_commit on: :create do
    Lms::PublicationJob.perform_later(self, 'created')
  end

  after_commit on: :update do
    Lms::PublicationJob.perform_later(self, 'updated')
  end

  def set_audit_user
    Audited.store[:audited_user] = Staff.find_by(id: created_by_id)
    Audited.store[:audited_user] = Staff.find_by(id: updated_by_id) if persisted?
  end
end

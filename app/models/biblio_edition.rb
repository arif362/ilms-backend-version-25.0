# frozen_string_literal: true

class BiblioEdition < ApplicationRecord
  audited
  has_many :biblios, dependent: :restrict_with_exception

  validates :title, presence: true
  validates_uniqueness_of :title, conditions: -> { where(is_deleted: false) }
  scope :not_deleted, -> { where(is_deleted: false) }
  before_save :set_audit_user
  after_commit on: :create do
    puts "created"
    Lms::EditionJob.perform_later(self, 'created')
  end

  after_commit on: :update do
    Lms::EditionJob.perform_later(self, 'updated')
  end

  def set_audit_user
    Audited.store[:audited_user] = Staff.find_by(id: created_by_id)
    Audited.store[:audited_user] = Staff.find_by(id: updated_by_id) if persisted?
  end
end

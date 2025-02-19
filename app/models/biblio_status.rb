class BiblioStatus < ApplicationRecord
  audited
  has_many :biblio_items, dependent: :restrict_with_exception

  enum status_type: { lost: 0, damage: 1, withdrawn: 2, discharge: 3, weed: 4 }
  validates_presence_of :status_type
  validates_uniqueness_of :title, scope: :status_type
  before_save :set_audit_user
  after_commit on: :create do
    Lms::StatusJob.perform_later(self, 'created')
  end

  after_commit on: :update do
    Lms::StatusJob.perform_later(self, 'updated')
  end

  def set_audit_user
    Audited.store[:audited_user] = Staff.find_by(id: created_by_id)
    Audited.store[:audited_user] = Staff.find_by(id: updated_by_id) if persisted?
  end
end

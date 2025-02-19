# frozen_string_literal: true

class LibraryLocation < ApplicationRecord
  audited
  belongs_to :library, optional: true
  has_many :permanent_biblio_items, class_name: 'BiblioItem', foreign_key: :permanent_library_location_id
  has_many :current_biblio_items, class_name: 'BiblioItem', foreign_key: :current_library_location_id
  has_many :shelving_biblio_items, class_name: 'BiblioItem', foreign_key: :shelving_library_location_id

  validates :code, presence: true
  validates_uniqueness_of :code, conditions: -> { where(is_deleted: false) }, scope: :library_id
  scope :not_deleted, -> { where(is_deleted: false) }

  before_save :set_audit_user

  enum :location_type => {'shelving': 0, 'current': 1, 'permanent': 2}


  def check_biblio_items_presence
    permanent_biblio_items.any? || current_biblio_items.any? || shelving_biblio_items.any?
  end

  after_commit on: :create do
    Lms::LocationJob.perform_later(self, 'created')
  end

  after_commit on: :update do
    Lms::LocationJob.perform_later(self, 'updated')
  end

  def set_audit_user
    Audited.store[:audited_user] = Staff.find_by(id: created_by_id)
    Audited.store[:audited_user] = Staff.find_by(id: updated_by_id) if persisted?
  end
end

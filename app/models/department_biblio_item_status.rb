class DepartmentBiblioItemStatus < ApplicationRecord
  audited

  has_many :department_biblio_items, dependent: :restrict_with_exception
  has_many :dep_biblio_item_status_changes, dependent: :restrict_with_exception

  STATUSES = {
    sent: { admin: 'Sent', publisher: 'Sent', bn_publisher_status: 'প্রেরিত' },
    received: { admin: 'Received', publisher: 'Received', bn_publisher_status: 'গৃহীত' }
  }.freeze

  enum status_key: {
    sent: 0,
    received: 1
  }

  def self.get_status(status_key)
    DepartmentBiblioItemStatus.find_by(status_key:)
  end
end

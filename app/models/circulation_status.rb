# frozen_string_literal: true

class CirculationStatus < ApplicationRecord
  has_many :circulations, dependent: :restrict_with_exception
  has_many :circulation_status_changes, dependent: :restrict_with_exception
  STATUSES = {
    borrowed: { admin: 'Borrowed', patron: 'Borrowed', bn_patron_status: 'ধার নেয়া', lms_status: 'Borrowed' },
    returned: { admin: 'Returned', patron: 'Returned', bn_patron_status: 'ফেরৎ', lms_status: 'Returned' },
    lost: { admin: 'Lost', patron: 'Lost', bn_patron_status: 'হারান', lms_status: 'Lost' },
    damaged_returned: { admin: 'Damaged Returned', patron: 'Damaged Returned', bn_patron_status: 'নষ্ট ফিরে এসেছে',
                        lms_status: 'Damaged Returned' }
  }.freeze
  enum status_key: {
    borrowed: 0,
    returned: 1,
    lost: 2,
    damaged_returned: 3
  }

  def self.get_status(status_key)
    CirculationStatus.find_by(status_key:)
  end
end

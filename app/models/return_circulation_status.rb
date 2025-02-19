class ReturnCirculationStatus < ApplicationRecord
  STATUSES = {
    pending: { admin: 'Pending', lms: 'Processing' },
    ready_for_pickup: { admin: 'Ready for pickup', lms: 'Ready for pickup' },
    collected_by_3pl: { admin: 'Collected by 3pl', lms: 'On the way' },
    delivered: { admin: 'Delivered', lms: 'Delivered' }
  }.freeze

  enum status_key: {
    pending: 0,
    ready_for_pickup: 1,
    collected_by_3pl: 2,
    delivered: 3
  }

  def self.get_status(status_key)
    ReturnCirculationStatus.find_by(status_key:)
  end
end

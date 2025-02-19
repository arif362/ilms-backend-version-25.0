class ReturnStatus < ApplicationRecord
  STATUSES = {
    initiated: { admin: 'Initiated', patron: 'Processing', bn_patron: 'প্রক্রিয়াধীন', lms: 'Processing' },
    collected_by_3pl: { admin: 'Collected by 3pl', patron: 'Returned', bn_patron: 'ফিরিয়ে দেওয়া হয়েছে',
                        lms: 'On the way' },
    cancelled: { admin: 'Cancelled', patron: 'Cancelled', bn_patron: 'বাতিল করা হয়েছে', lms: 'Cancelled' },
    delivered_to_library: { admin: 'Delivered To Library', patron: 'Returned', bn_patron: 'ফিরিয়ে দেওয়া হয়েছে',
                            lms: 'Delivered' },
    returned_at_other_library: { admin: 'Returned at Other Library', patron: 'Returned',
                                 bn_patron: 'ফিরিয়ে দেওয়া হয়েছে', lms: 'Returned at other library' }
  }.freeze

  enum status_key: {
    initiated: 0,
    collected_by_3pl: 1,
    cancelled: 2,
    delivered_to_library: 3,
    returned_at_other_library: 4
  }

  has_many :return_status_changes, dependent: :restrict_with_exception
  has_many :return_orders, dependent: :restrict_with_exception

  def self.get_status(status_key)
    ReturnStatus.find_by(status_key:)
  end
end

class CardStatus < ApplicationRecord
  STATUSES = {
    waiting_for_print: { admin: 'Waiting for print', patron: 'Processing', bn_patron_status: 'প্রক্রিয়াধীন', lms_status: 'Processing' },
    printed: { admin: 'Order Confirmed', patron: 'Processing', bn_patron_status: 'প্রক্রিয়াধীন',
               lms_status: 'Processing' },
    ready_for_pickup: { admin: 'Ready for pick up', patron: 'Processing', bn_patron_status: 'প্রক্রিয়াধীন',
                        lms_status: 'Processing' },
    collected_by_3pl: { admin: 'Collected by 3pl', patron: 'On the way', bn_patron_status: 'যাত্রাপথে আছে',
                        lms_status: 'On the way' },
    cancelled: { admin: 'Cancelled', patron: 'Cancelled', bn_patron_status: 'বাতিল করা হয়েছে', lms_status: 'Cancelled' },
    delivered: { admin: 'Delivered', patron: 'Delivered', bn_patron_status: 'ডেলিভারী করা হয়েছে', lms_status: 'Delivered' },
    delivered_to_library: { admin: 'Delivered To Library', patron: 'Delivered To Library', bn_patron_status: 'পাঠাগারে বিতরণ করা হয়েছে',
                            lms_status: 'Delivered To Library' },
    on_hold: { admin: 'On Hold', patron: 'On Hold', bn_patron_status: 'প্রক্রিয়াধীন', lms_status: 'On Hold' },
    rejected: { admin: 'Rejected', patron: 'Rejected', bn_patron_status: 'প্রত্যাখ্যাত', lms_status: 'Rejected' },
    accepted: { admin: 'Accepted', patron: 'Accepted', bn_patron_status: 'গ্রহণ করা হয়েছে', lms_status: 'Accepted' },
    pending: { admin: 'Pending', patron: 'Pending', bn_patron_status: 'প্রক্রিয়াকরণ', lms_status: 'Pending' }
  }.freeze
  FINISHED_STATUSES = %w[cancelled delivered rejected].freeze

  enum status_key: {
    waiting_for_print: 0,
    printed: 1,
    ready_for_pickup: 2,
    collected_by_3pl: 3,
    cancelled: 4,
    delivered: 5,
    delivered_to_library: 6,
    on_hold: 7,
    rejected: 8,
    accepted: 9,
    pending: 10
  }

  has_many :card_status_changes, dependent: :restrict_with_exception
  has_many :library_cards, dependent: :restrict_with_exception

  default_scope { where(is_deleted: false) }
  scope :active, -> { where(active: true) }

  def self.get_status(status_key)
    CardStatus.find_by(status_key:)
  end

  def self.finished_statuses
    CardStatus.where(status_key: %i[rejected cancelled delivered])
  end
end

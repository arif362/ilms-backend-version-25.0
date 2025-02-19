# frozen_string_literal: true

class TransferOrderStatus < ApplicationRecord
  has_many :library_transfer_orders, dependent: :restrict_with_exception
  has_many :transfer_order_status_changes, dependent: :restrict_with_exception
  STATUSES = {
    pending: { admin: 'Pending', patron: 'Processing', bn_patron_status: 'প্রক্রিয়াধীন', lms_status: 'Processing' },
    initiated: { admin: 'initiated', patron: 'initiated', bn_patron_status: 'প্রক্রিয়াধীন', lms_status: 'initiated' },
    accepted: { admin: 'Accepted', patron: 'Processing', bn_patron_status: 'প্রক্রিয়াধীন',
                lms_status: 'Accepted' },
    rejected: { admin: 'Rejected', patron: 'Rejected', bn_patron_status: 'প্রত্যাখ্যাত',
                lms_status: 'Rejected' },
    in_transit: { admin: 'In-Transit', patron: 'In-Transit', bn_patron_status: 'যাত্রাপথে আছে',
                  lms_status: 'On the way' },
    delivered: { admin: 'Delivered', patron: 'Delivered', bn_patron_status: 'ডেলিভারী করা হয়েছে',
                 lms_status: 'Delivered' }
  }.freeze
  enum status_key: {
    pending: 0,
    accepted: 1,
    rejected: 2,
    in_transit: 3,
    delivered: 4,
    initiated: 5
  }

  def self.get_status(status_key)
    TransferOrderStatus.find_by(status_key:)
  end
end

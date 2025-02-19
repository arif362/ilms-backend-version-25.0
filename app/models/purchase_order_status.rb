# frozen_string_literal: true

class PurchaseOrderStatus < ApplicationRecord
  has_many :purchase_orders, dependent: :restrict_with_exception
  has_many :po_status_changes, dependent: :restrict_with_exception

  STATUSES = {
    pending: { admin: 'Pending', publisher: 'Pending', bn_publisher_status: 'প্রক্রিয়াধীন' },
    approved: { admin: 'Approved', publisher: 'Approved', bn_publisher_status: 'অনুমোদিত' },
    sent: { admin: 'Sent', publisher: 'Sent', bn_publisher_status: 'প্রেরিত' },
    partially_received: { admin: 'Partially Received', publisher: 'Partially Received', bn_publisher_status: 'আংশিকভাবে প্রাপ্ত'},
    received: { admin: 'Received', publisher: 'Received', bn_publisher_status: 'গৃহীত' },
    cancelled: { admin: 'Cancelled', publisher: 'Cancelled', bn_publisher_status: 'বাতিল' }
  }.freeze

  enum status_key: {
    pending: 0,
    approved: 1,
    sent: 2,
    partially_received: 3,
    received: 4,
    cancelled: 5
  }
  def self.get_status(status_key)
    PurchaseOrderStatus.find_by(status_key:)
  end

  STATUS_EXCEPT_RECEIVED = %w[pending approved sent cancelled].freeze
end

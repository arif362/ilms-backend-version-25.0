class OrderStatus < ApplicationRecord
  STATUSES = {
    order_placed: { admin: 'Order Placed', patron: 'Order Placed',
                    bn_patron_status: 'অর্ডার স্থাপন করা হয়েছে', lms_status: 'Processing', three_ps_status: 'no status' },
    order_confirmed: { admin: 'Order Confirmed', patron: 'Order Confirmed',
                       bn_patron_status: 'নিশ্চিত করা হয়েছে', lms_status: 'Processing', three_ps_status: 'no status' },
    ready_for_pickup: { admin: 'Ready for pick up', patron: 'Ready to Shipment', bn_patron_status: 'পাঠানোর জন্য প্রস্তুত',
                        lms_status: 'Processing', three_ps_status: 'parcel notice sent to third party' },
    collected_by_3pl: { admin: 'Collected by 3pl', patron: 'In-Transit', bn_patron_status: 'যাত্রাপথে আছে',
                        lms_status: 'On the way', three_ps_status: 'delivery-in-progress' },
    cancelled: { admin: 'Cancelled', patron: 'Cancelled', bn_patron_status: 'বাতিল করা হয়েছে',
                 lms_status: 'Cancelled', three_ps_status: 'agent-hold' },
    delivered: { admin: 'Delivered', patron: 'Delivered', bn_patron_status: 'ডেলিভারী করা হয়েছে',
                 lms_status: 'Delivered', three_ps_status: 'delivered' },
    delivered_to_library: { admin: 'Delivered to Library', patron: 'Delivered to your desired library', bn_patron_status: 'ডেলিভারী করা হয়েছে',
                            lms_status: 'Delivered to library', three_ps_status: 'no status' },
    rejected: { admin: 'Rejected', patron: 'Rejected', bn_patron_status: 'প্রত্যাখ্যাত করা হয়েছে',
                lms_status: 'Rejected', three_ps_status: 'no status' }
  }.freeze

  enum status_key: {
    order_placed: 0,
    cancelled: 1,
    order_confirmed: 2,
    rejected: 3,
    ready_for_pickup: 4,
    collected_by_3pl: 5,
    delivered_to_library: 6,
    delivered: 7
  }

  PATRON_VIEWABLE = %w[processing cancelled on_the_way ready_for_pickup delivered rejected delivered_to_library].freeze
  FINISHED_STATUSES = %w[delivered cancelled].freeze
  NOT_ON_HAND_STATUSES = %w[cancelled rejected].freeze

  has_many :order_status_changes, dependent: :restrict_with_exception
  has_many :orders, dependent: :restrict_with_exception

  def self.get_status(status_key)
    OrderStatus.find_by(status_key:)
  end

  def self.under_process_orders
    OrderStatus.where(status_key: %i[order_placed order_confirmed ready_for_pickup]).ids
  end
end

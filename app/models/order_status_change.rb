class OrderStatusChange < ApplicationRecord
  default_scope -> { order(id: :asc) }

  belongs_to :order
  belongs_to :order_status
  belongs_to :changed_by, polymorphic: true, optional: true

  scope :for_patron, -> { joins(:order_status).where('order_statuses.system_status IN (?)', OrderStatus::PATRON_VIEWABLE) }
end

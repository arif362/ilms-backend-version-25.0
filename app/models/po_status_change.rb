class PoStatusChange < ApplicationRecord
  belongs_to :purchase_order
  belongs_to :purchase_order_status
  belongs_to :changed_by, polymorphic: true, optional: true
end

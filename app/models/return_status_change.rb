class ReturnStatusChange < ApplicationRecord
  default_scope -> { order(id: :asc) }

  belongs_to :return_order
  belongs_to :return_status
  belongs_to :changed_by, polymorphic: true, optional: true
end

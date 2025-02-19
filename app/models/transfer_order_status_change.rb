# frozen_string_literal: true

class TransferOrderStatusChange < ApplicationRecord
  belongs_to :library_transfer_order
  belongs_to :transfer_order_status
  belongs_to :changed_by, polymorphic: true, optional: true
end

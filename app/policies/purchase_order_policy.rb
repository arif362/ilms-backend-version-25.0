# frozen_string_literal: true

class PurchaseOrderPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :PURCHASE_ORDER)
  end

  def po_received?
    permission?("#{@access_module.to_s.downcase}-receive")
  end
end

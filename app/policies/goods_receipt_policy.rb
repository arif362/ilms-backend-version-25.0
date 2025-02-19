# frozen_string_literal: true

class GoodsReceiptPolicy < ApplicationPolicy
  def initialize(current_user, record)
    super(current_user, record, :GOODS_RECEIPT)
  end
end

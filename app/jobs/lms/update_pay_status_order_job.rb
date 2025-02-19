module Lms

  class UpdatePayStatusOrderJob < ApplicationJob
    queue_as :default

    def perform(order)
      Lms::OrderManage::UpdatePayStatusOrder.call(order:)
    end
  end
end

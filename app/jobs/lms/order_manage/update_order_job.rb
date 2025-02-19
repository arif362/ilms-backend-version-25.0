# frozen_string_literal: true

module Lms
  module OrderManage
    class UpdateOrderJob < ApplicationJob
      queue_as :default

      def perform(order, user_able)
        Lms::OrderManage::UpdateOrder.call(order:, user_able:)
      end
    end
  end
end

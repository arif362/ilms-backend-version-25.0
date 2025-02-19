# frozen_string_literal: true

module Lms
  module OrderManage
    class CreateOrderJob < ApplicationJob
      queue_as :default

      def perform(order, user_able)
        Lms::OrderManage::CreateOrder.call(order:, user_able:)
      end
    end
  end
end

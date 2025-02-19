# frozen_string_literal: true

module Lms
  module OrderManage
    class CreateExtendRequestJob < ApplicationJob
      queue_as :default

      def perform(extend_request, user_able)
        Lms::OrderManage::CreateExtendRequest.call(extend_request:, user_able:)
      end
    end
  end
end

# frozen_string_literal: true

module Lms
  module ReturnOrderManagement
    class RoTransitStatusUpdateJob < ApplicationJob
      queue_as :default

      def perform(return_order, user_able)
        Lms::ReturnOrderManagement::RoTransitStatusUpdate.call(return_order:, user_able:)
      end
    end
  end
end

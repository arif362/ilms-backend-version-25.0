# frozen_string_literal: true

module Lms
  module CardPrintManagement
    class OutgoingStatusUpdateJob < ApplicationJob
      queue_as :default

      def perform(card, status, user_able)
        Lms::CardPrintManagement::OutgoingStatusUpdate.call(library_card: card, status:, user_able:)
      end
    end
  end
end

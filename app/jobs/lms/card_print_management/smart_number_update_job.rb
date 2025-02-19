# frozen_string_literal: true

module Lms
  module CardPrintManagement
    class SmartNumberUpdateJob < ApplicationJob
      queue_as :default

      def perform(card, user_able)
        Lms::CardPrintManagement::SmartNumberUpdate.call(card:, user_able:)
      end
    end
  end
end

# frozen_string_literal: true

module Lms
  module CardPrintManagement
    class CreateCardPrintJob < ApplicationJob
      queue_as :default

      def perform(library_card, user_able)
        Lms::CardPrintManagement::CreateCardPrint.call(library_card:, user_able:)
      end
    end
  end
end

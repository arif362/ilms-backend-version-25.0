# frozen_string_literal: true

module Lms
  module CardPrintManagement
    class IssuedLibraryDeliverStatusJob < ApplicationJob
      queue_as :default

      def perform(library_card, user_able)
        Lms::CardPrintManagement::IssuedLibraryDeliverStatus.call(library_card:, user_able:)
      end
    end
  end
end

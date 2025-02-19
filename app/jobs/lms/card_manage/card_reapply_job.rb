# frozen_string_literal: true

module Lms
  module CardManage
    class CardReapplyJob < ApplicationJob
      queue_as :default

      def perform(library_card)
        Lms::CardManage::CardReapply.call(library_card:)
      end
    end
  end
end

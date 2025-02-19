# frozen_string_literal: true

module Lms
  class UpdateCardStatusJob < ApplicationJob
    queue_as :default

    def perform(card, user_able)
      Lms::UpdateCardStatus.call(card:, user_able:)
    end
  end
end

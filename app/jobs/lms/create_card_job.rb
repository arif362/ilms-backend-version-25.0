# frozen_string_literal: true

module Lms
  class CreateCardJob < ApplicationJob
    queue_as :default

    def perform(request_details, user_able)
      Lms::CreateCard.call(request_details:, user_able:)
    end
  end
end

# frozen_string_literal: true

module Lms
  class EventRegistrationJob < ApplicationJob
    queue_as :default

    def perform(registered_event, action_type)
      Lms::EventRegistrationService.call(registered_event:, action_type:)
    end
  end
end

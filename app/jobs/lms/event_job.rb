# frozen_string_literal: true

module Lms
  class EventJob < ApplicationJob
    queue_as :default

    def perform(event, action_type)
      Lms::GlobalEvent.call(event:, action_type:)
    end
  end
end

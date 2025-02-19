# frozen_string_literal: true

module Lms
  class StatusJob < ApplicationJob
    queue_as :default

    def perform(status, action_type)
      Lms::Statuses.call(status:, action_type:)
    end
  end
end

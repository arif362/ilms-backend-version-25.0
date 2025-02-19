# frozen_string_literal: true

module Lms
  class ClassificationJob < ApplicationJob
    queue_as :default

    def perform(classification, action_type)
      Lms::Classifications.call(classification:, action_type:)
    end
  end
end

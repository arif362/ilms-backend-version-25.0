# frozen_string_literal: true

module Lms
  class SubjectJob < ApplicationJob
    queue_as :default

    def perform(subject, action_type)
      Lms::Subjects.call(subject:, action_type:)
    end
  end
end

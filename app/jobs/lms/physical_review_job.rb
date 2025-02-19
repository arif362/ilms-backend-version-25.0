# frozen_string_literal: true

module Lms
  class PhysicalReviewJob < ApplicationJob
    queue_as :default

    def perform(physical_review, action_type)
      Lms::PhysicalBookReviews.call(physical_review:, action_type:)
    end
  end
end

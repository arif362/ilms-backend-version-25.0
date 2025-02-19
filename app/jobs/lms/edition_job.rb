# frozen_string_literal: true

module Lms
  class EditionJob < ApplicationJob
    queue_as :default

    def perform(edition, action_type)
      Lms::Editions.call(edition:, action_type:)
    end
  end
end

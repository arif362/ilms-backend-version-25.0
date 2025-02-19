# frozen_string_literal: true

module Lms
  class LocationJob < ApplicationJob
    queue_as :default

    def perform(location, action_type)
      Lms::Locations.call(location:, action_type:)
    end
  end
end

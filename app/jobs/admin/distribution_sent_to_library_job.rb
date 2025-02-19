# frozen_string_literal: true

module Admin
  class DistributionSentToLibraryJob < ApplicationJob
    queue_as :default

    def perform(distribution, action_type)
      Admin::DistributionSentToLibrary.call(distribution:, action_type:)
    end
  end
end

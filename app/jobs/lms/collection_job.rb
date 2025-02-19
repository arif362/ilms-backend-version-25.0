# frozen_string_literal: true

module Lms
  class CollectionJob < ApplicationJob
    queue_as :default

    def perform(collection, action_type)
      Lms::CollectionLms.call(collection:, action_type:)
    end
  end
end

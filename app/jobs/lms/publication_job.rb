# frozen_string_literal: true

module Lms
  class PublicationJob < ApplicationJob
    queue_as :default

    def perform(publication, action_type)
      Lms::Publications.call(publication:, action_type:)
    end
  end
end

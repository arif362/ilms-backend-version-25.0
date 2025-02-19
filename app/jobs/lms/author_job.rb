# frozen_string_literal: true

module Lms
  class AuthorJob < ApplicationJob
    queue_as :default

    def perform(author, action_type)
      Lms::Authors.call(author:, action_type:)
    end
  end
end

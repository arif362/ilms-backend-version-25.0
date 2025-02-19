# frozen_string_literal: true

module Lms
  class CreateUserJob < ApplicationJob
    queue_as :default

    def perform(request_detail, user_identity, user_able)
      Lms::CreateUser.call(request_detail:, user_identity:, user_able:)
    end
  end
end

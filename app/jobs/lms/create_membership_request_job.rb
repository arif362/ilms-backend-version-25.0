# frozen_string_literal: true

module Lms
  class CreateMembershipRequestJob < ApplicationJob
    queue_as :default

    def perform(membership_request, user_able)
      Lms::CreateMembershipRequest.call(membership_request:, user_able:)
    end
  end
end

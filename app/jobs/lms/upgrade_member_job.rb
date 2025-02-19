# frozen_string_literal: true

module Lms
  class UpgradeMemberJob < ApplicationJob
    queue_as :default

    def perform(request_detail, user_identity, user_able)
      Lms::UpgradeMember.call(request_detail:, user_identity:, user_able:)
    end
  end
end

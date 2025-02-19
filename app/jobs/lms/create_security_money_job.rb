# frozen_string_literal: true

module Lms
  class CreateSecurityMoneyJob < ApplicationJob
    queue_as :default

    def perform(payment, user_able)
      Lms::CreateSecurityMoney.call(payment:, user_able:)
    end
  end
end

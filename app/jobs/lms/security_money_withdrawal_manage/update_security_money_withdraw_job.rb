# frozen_string_literal: true

module Lms
  module SecurityMoneyWithdrawalManage
    class UpdateSecurityMoneyWithdrawJob < ApplicationJob
      queue_as :default

      def perform(request_details, user_able)
        Lms::SecurityMoneyWithdrawalManage::UpdateSecurityMoneyWithdraw.call(request_details:, user_able:)
      end
    end
  end
end

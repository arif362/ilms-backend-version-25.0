# frozen_string_literal: true

module Lms
  module MemberInfoManage
    class ChangePhoneJob < ApplicationJob
      queue_as :default

      def perform(user)
        Rails.logger.error " ---- job---  #{user.inspect}"
        Lms::MemberInfoManage::ChangePhone.call(user:)
      end
    end
  end
end

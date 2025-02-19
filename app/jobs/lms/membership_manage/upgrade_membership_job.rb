# frozen_string_literal: true

module Lms
  module MembershipManage
    class UpgradeMembershipJob < ApplicationJob
      queue_as :default

      def perform(membership_request, user_able)
        Lms::MembershipManage::UpgradeMembership.call(membership_request:, user_able:)
      end
    end
  end
end

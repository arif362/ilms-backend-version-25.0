# frozen_string_literal: true

module Lms
  module MembershipManage
    class RenewMembershipJob < ApplicationJob
      queue_as :default

      def perform(membership_request, user_able)
        Lms::MembershipManage::RenewMembership.call(membership_request:, user_able:)
      end
    end
  end
end

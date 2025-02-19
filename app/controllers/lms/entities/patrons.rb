# frozen_string_literal: true

module Lms
  module Entities
    class Patrons < Grape::Entity
      include Lms::Helpers::ImageHelpers

      expose :id
      expose :unique_id, as: :formated_id
      expose :full_name
      expose :email
      expose :phone
      expose :dob
      expose :gender
      expose :image, as: :profile_image_url, format_with: :image_path
      expose :addresses
      expose :membership_request
      expose :member

      def membership_request
        Lms::Entities::MembershipRequests.represent(object.membership_requests&.last)
      end

      def addresses
        object.saved_addresses
        PublicLibrary::Entities::SavedAddresses.represent(object.saved_addresses, lan: options[:request_source] )
      end

      def member_status
        member&.active ? 'Active' : 'Inactive'
      end

      def member
        object&.member
      end

      def balance
        object.security_moneys&.available&.sum(:amount) || 0
      end

      def member_activated_at
        member&.activated_at
      end

      def is_money_withdraw_requested
        object.security_money_requests&.present?
      end
    end
  end
end

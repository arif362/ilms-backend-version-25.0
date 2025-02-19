# frozen_string_literal: true

module PublicLibrary
  module Entities
    class Users < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :id
      expose :unique_id
      expose :full_name
      expose :email
      expose :phone
      expose :dob
      expose :gender
      expose :is_publisher
      expose :is_member
      expose :member
      expose :is_membership
      expose :member_status
      expose :last_saved_address
      expose :balance
      expose :member_activated_at
      expose :is_money_withdraw_requested
      expose :image, as: :profile_image_url, format_with: :image_path

      def is_member
        member&.present? && member&.active ? true : false
      end

      def is_publisher
        object&.publisher.present? ? true : false
      end

      def last_saved_address
        object&.saved_addresses&.last
      end

      def is_membership
        object.membership_requests.present?
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

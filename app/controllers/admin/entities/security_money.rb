# frozen_string_literal: true

module Admin
  module Entities
    class SecurityMoney < Grape::Entity
      expose :id
      expose :member_id
      expose :name
      expose :membership_type
      expose :payment_method
      expose :status
      expose :amount
      expose :library
      expose :created_at, as: :deposited_at

      def library
        object.library.as_json(only: %i[id code name])
      end
      def name
        object.member.user.full_name
      end

      def membership_type
        object.member.membership_category
      end
    end
  end
end

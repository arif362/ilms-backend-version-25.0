# frozen_string_literal: true

module Lms
  module Entities
    class SecurityMoneyRequests < Grape::Entity
      expose :id
      expose :user
      expose :amount
      expose :status
      expose :payment_method
      expose :note
      expose :created_at

      def user
        object.user.as_json(only: %i[id full_name phone])
      end

      def payment_method
        object.pickup_from_library? ? 'cash' : 'digital'
      end
    end
  end
end

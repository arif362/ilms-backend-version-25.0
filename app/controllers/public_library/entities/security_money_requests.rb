# frozen_string_literal: true

module PublicLibrary
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
    end
  end
end

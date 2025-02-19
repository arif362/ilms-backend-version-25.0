# frozen_string_literal: true

module Admin
  module Entities
    class SecurityMoneyRequest < Grape::Entity
      expose :id
      expose :name
      expose :phone
      expose :payment_method
      expose :status
      expose :amount
      expose :library
      expose :created_at, as: :request_date

      def library
        object.library.as_json(only: %i[id code name])
      end

      def name
        object.user.full_name
      end

      def phone
        object.user&.phone
      end
    end
  end
end

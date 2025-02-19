module Admin
  module Entities
    class Payments < Grape::Entity
      include Admin::Helpers::ImageHelpers
      expose :id
      expose :status
      expose :trx_id
      expose :invoice_id
      expose :payment_type
      expose :amount
      expose :phone
      expose :member_name
      expose :library
      expose :purpose
      expose :member_unique_id
      expose :created_at, as: :payment_at

      def member_name
        object.user&.full_name
      end

      def member_unique_id
        object.member&.unique_id
      end

      def phone
        object.user&.phone
      end

      def library
        object.member&.library&.as_json(only: %i[id name code])
      end
    end
  end
end

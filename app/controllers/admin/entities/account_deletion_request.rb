# frozen_string_literal: true

module Admin
  module Entities
    class AccountDeletionRequest < Grape::Entity
      format_with(:iso_date, &:to_date)

      expose :id
      expose :user
      expose :status
      expose :reason
      expose :created_at, as: :request_date, format_with: :iso_date

      def user
        user = object&.user
        {
          id: user&.id,
          full_name: user&.full_name,
          unique_id: user&.member&.unique_id,
          phone: user&.phone
        }
      end
    end
  end
end

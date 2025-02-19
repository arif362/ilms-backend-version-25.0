# frozen_string_literal: true

module PublicLibrary
  module Entities
    class Payments < Grape::Entity
      expose :id
      expose :payment_type, as: :payment_method
      expose :status
      expose :amount
      expose :trx_id
      expose :purpose
      expose :created_at
    end
  end
end

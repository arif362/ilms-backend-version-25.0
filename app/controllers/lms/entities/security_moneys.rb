# frozen_string_literal: true

module Lms
  module Entities
    class SecurityMoneys < Grape::Entity
      expose :amount
      expose :payment_method
    end
  end
end

# frozen_string_literal: true

module PublicLibrary
  module Entities
    class SecurityMoneys < Grape::Entity
      expose :id
      expose :amount
      expose :payment_method
    end
  end
end

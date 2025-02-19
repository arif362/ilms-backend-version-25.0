# frozen_string_literal: true

module PublicLibrary
  module Entities
    class Invoice < Grape::Entity
      expose :id
      expose :invoice_type
      expose :invoice_status
      expose :invoice_amount
      expose :payments, using: PublicLibrary::Entities::Payments

    end
  end
end

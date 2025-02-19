# frozen_string_literal: true
module ThreePs

  class CreateParcelJob < ApplicationJob
    queue_as :default

    def perform(order)
      ParcelManagement::Orders::CreateParcel.call(order:)
    end
  end
end

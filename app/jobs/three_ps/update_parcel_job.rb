# frozen_string_literal: true
module ThreePs

  class UpdateParcelJob < ApplicationJob
    queue_as :default

    def perform(order)
      ParcelManagement::Orders::UpdateParcel.call(order:)
    end
  end
end

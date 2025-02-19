# frozen_string_literal: true
module ThreePs

  class CreatePickUpStoreJob < ApplicationJob
    queue_as :default

    def perform(library)
      ParcelManagement::PickUpStores::CreatePickUpStore.call(library:)
    end
  end
end

# frozen_string_literal: true

module PublicLibrary
  module Entities
    class TransferOrderStatusDropdown < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers
      expose :id
      expose :system_status
      expose :patron_status

    end
  end
end

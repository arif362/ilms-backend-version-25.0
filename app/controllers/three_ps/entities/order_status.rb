# frozen_string_literal: true

module ThreePs
  module Entities
    class OrderStatus < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :id
      expose :created_at
      expose :status_key
      expose :patron_status
    end
  end
end

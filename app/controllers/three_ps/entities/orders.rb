# frozen_string_literal: true

module ThreePs
  module Entities
    class Orders < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers
      expose :tracking_id
      expose :created_at, as: :order_placed_date
      expose :status
      expose :timestamp

      def status
        order_status.three_ps_status
      end

      def timestamp
        order_status.created_at
      end
    end
  end
end

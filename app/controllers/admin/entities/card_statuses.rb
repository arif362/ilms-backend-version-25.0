# frozen_string_literal: true

module Admin
  module Entities
    class CardStatuses < Grape::Entity
      expose :id
      expose :status_key
      expose :admin_status
    end
  end
end

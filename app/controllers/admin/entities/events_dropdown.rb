# frozen_string_literal: true

module Admin
  module Entities
    class EventsDropdown < Grape::Entity
      expose :id
      expose :title
    end
  end
end

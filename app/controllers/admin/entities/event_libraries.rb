# frozen_string_literal: true

module Admin
  module Entities
    class EventLibraries < Grape::Entity
      expose :id
      expose :library, using: Admin::Entities::Libraries
      expose :total_registered
    end
  end
end

# frozen_string_literal: true

module Admin
  module Entities
    class EventRegistrations < Grape::Entity
      expose :id
      expose :user_id
      expose :name
      expose :phone
      expose :email
      expose :address
      expose :identity_type
      expose :identity_number
      expose :father_name
      expose :mother_name
      expose :profession
      expose :library, using: Admin::Entities::Libraries
    end
  end
end

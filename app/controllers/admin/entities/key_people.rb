# frozen_string_literal: true

module Admin
  module Entities
    class KeyPeople < Grape::Entity
      expose :id
      expose :name
      expose :bn_name
      expose :designation
    end
  end
end

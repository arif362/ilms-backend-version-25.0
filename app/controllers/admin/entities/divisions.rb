# frozen_string_literal: true

module Admin
  module Entities
    class Divisions < Grape::Entity
      expose :id
      expose :name
      expose :bn_name
    end
  end
end

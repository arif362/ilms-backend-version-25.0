# frozen_string_literal: true

module ThreePs
  module Entities
    class Thanas < Grape::Entity
      expose :name
      expose :bn_name
    end
  end
end

# frozen_string_literal: true

module Lms
  module Entities
    class DistrictDropdown < Grape::Entity
      expose :id
      expose :name
      expose :bn_name
    end
  end
end

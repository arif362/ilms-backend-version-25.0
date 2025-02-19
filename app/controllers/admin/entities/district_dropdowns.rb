module Admin
  module Entities
    class DistrictDropdowns < Grape::Entity
      expose :id
      expose :name
    end
  end
end

module Admin
  module Entities
    class Designations < Grape::Entity
      expose :id
      expose :title
    end
  end
end

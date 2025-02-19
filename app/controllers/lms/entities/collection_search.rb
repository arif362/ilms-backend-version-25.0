module Lms
  module Entities
    class CollectionSearch < Grape::Entity
      expose :id
      expose :title
    end
  end
end


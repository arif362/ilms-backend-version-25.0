module Admin
  module Entities
    class LineItems < Grape::Entity
      expose :id
      expose :biblio, using: Admin::Entities::BiblioList
      expose :price
    end
  end
end

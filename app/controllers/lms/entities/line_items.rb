module Lms
  module Entities
    class LineItems < Grape::Entity
      expose :id
      expose :biblio, using: Lms::Entities::BiblioList
      expose :biblio_item, using: Lms::Entities::BiblioItems
    end
  end
end

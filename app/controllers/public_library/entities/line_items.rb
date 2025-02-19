module PublicLibrary
  module Entities
    class LineItems < Grape::Entity
      expose :id
      expose :biblio, using: PublicLibrary::Entities::Biblios
    end
  end
end

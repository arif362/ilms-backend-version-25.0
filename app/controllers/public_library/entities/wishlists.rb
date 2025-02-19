module PublicLibrary
  module Entities
    class Wishlists < Grape::Entity
      expose :id
      expose :biblio, using: PublicLibrary::Entities::BiblioDetails
    end
  end
end

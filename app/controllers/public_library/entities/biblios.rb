# frozen_string_literal: true

module PublicLibrary
  module Entities
    class Biblios < Grape::Entity
      expose :authors, using: PublicLibrary::Entities::Authors
      expose :title
      expose :slug
      expose :remainder_of_title
      expose :isbn
      expose :biblio_edition, using: PublicLibrary::Entities::BiblioEditions
      expose :biblio_publication, using: PublicLibrary::Entities::BiblioPublications
      expose :corporate_name
      expose :place_of_publication
      expose :date_of_publication
      expose :average_rating
      expose :total_reviews
    end
  end
end

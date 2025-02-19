# frozen_string_literal: true

module Admin
  module Entities
    class BiblioList < Grape::Entity
      expose :id
      expose :title
      expose :is_e_biblio
      expose :isbn
      expose :biblio_publication

      def biblio_publication
        biblio_publication = BiblioPublication.find_by(id: object.biblio_publication_id)
        {
          id: biblio_publication&.id,
          title: biblio_publication&.title
        }
      end
    end
  end
end

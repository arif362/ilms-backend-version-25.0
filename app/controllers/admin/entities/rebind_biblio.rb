# frozen_string_literal: true

module Admin
  module Entities
    class RebindBiblio < Grape::Entity
      expose :id
      expose :status
      expose :biblio_item_id
      expose :title
      expose :accession_no
      expose :library

      def title
        object.biblio.title
      end

      def accession_no
        object.biblio_item.accession_no
      end

      def library
        library = object.library
        {
          id: library.id,
          code: library.code
        }
      end
    end
  end
end

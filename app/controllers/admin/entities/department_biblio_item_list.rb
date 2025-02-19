module Admin
  module Entities
    class DepartmentBiblioItemList < Grape::Entity
      expose :id
      expose :biblio_info
      expose :central_accession_no
      expose :purchase_order_no
      expose :memorandum_no

      def biblio_info
        publisher_biblio = object&.publisher_biblio
        {
          id: publisher_biblio&.id,
          title: publisher_biblio&.title,
          author_name: publisher_biblio&.author_name,
          publication_name: publisher_biblio&.publisher&.publication_name
        }
      end

      def purchase_order_no
        object&.po_line_item&.purchase_order_id
      end

      def memorandum_no
        object&.po_line_item&.purchase_order&.memorandum&.memorandum_no
      end

    end
  end
end

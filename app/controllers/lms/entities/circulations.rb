module Lms
  module Entities
    class Circulations< Grape::Entity
      expose :id
      expose :biblio_title
      expose :returned_at, as: :returned_date
      expose :return_at, as: :due_date
      expose :created_at, as: :issue_date
      expose :status
      expose :price
      expose :isbn
      expose :accession_number

      def isbn
        object.biblio_item&.biblio&.isbn
      end

      def accession_number
        object.biblio_item&.accession_no
      end

      def biblio_title
        object.biblio_item&.biblio&.title
      end

      def status
        object.circulation_status.lms_status
      end

      def price
        object.biblio_item&.price
      end
    end
  end
end

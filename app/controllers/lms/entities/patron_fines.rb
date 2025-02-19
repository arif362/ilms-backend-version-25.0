# frozen_string_literal: true

module Lms
  module Entities
    class PatronFines < Grape::Entity
      include Lms::Helpers::ImageHelpers

      expose :id, as: :invoice_id
      expose :title
      expose :authors
      expose :accession_no
      expose :fine_type
      expose :created_at, as: :fine_created
      expose :invoice_amount
      expose :invoice_status, as: :status

      def accession_no
        biblio_item&.accession_no
      end

      def title
        biblio_item&.biblio&.title
      end

      def authors
        biblio_item&.biblio&.authors&.map(&:full_name)
      end

      def biblio_item
        object&.invoiceable&.biblio_item
      end

      def fine_type
        object&.invoiceable.is_a?(Circulation) ? 'Loan' : object&.invoiceable&.status
      end

    end
  end
end

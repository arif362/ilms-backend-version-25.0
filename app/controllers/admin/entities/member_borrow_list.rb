# frozen_string_literal: true

module Admin
  module Entities
    class MemberBorrowList < Grape::Entity
      expose :id
      expose :authors
      expose :biblio_info
      expose :accession
      expose :created_at, as: :issue_date
      expose :return_at, as: :return_date

      def authors
        biblio&.authors&.map(&:full_name)
      end

      def biblio_info
        biblio&.as_json(only: %i[id title])
      end

      def biblio
        object.biblio_item.biblio
      end

      def accession
        object&.biblio_item&.accession_no
      end
    end
  end
end

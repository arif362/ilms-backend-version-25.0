# frozen_string_literal: true

module Admin
  module Entities
    class CirculationDetails < Grape::Entity
      expose :id
      expose :biblio_item
      expose :user
      expose :created_at, as: :issued_date
      expose :return_at, as: :return_date

      def biblio_item
        {
          id: object.biblio_item_id,
          accession_no: object.biblio_item&.accession_no,
          title: object.biblio_item&.biblio&.title
        }
      end

      def user
        {
          id: object.member_id,
          unique_id: object.member&.unique_id,
          full_name: object.member&.user&.full_name
        }
      end
    end
  end
end

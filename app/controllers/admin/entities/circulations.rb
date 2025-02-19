# frozen_string_literal: true

module Admin
  module Entities
    class Circulations < Grape::Entity
      expose :id
      expose :biblio_item
      expose :user
      expose :circulation_status
      expose :updated_at, as: :lost_at

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

      def circulation_status
        circulation_status = object.circulation_status
        {
          id: circulation_status.id,
          status: circulation_status.admin_status
        }
      end
    end
  end
end

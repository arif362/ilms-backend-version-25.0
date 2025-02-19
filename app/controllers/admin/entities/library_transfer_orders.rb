# frozen_string_literal: true

module Admin
  module Entities
    class LibraryTransferOrders < Grape::Entity
      expose :id
      expose :biblio_title
      expose :isbn
      expose :receiver_library
      expose :sender_library
      expose :order_type
      expose :transfer_order_status
      expose :created_at
      expose :return_at

      def biblio_title
        object.biblio&.title
      end

      def isbn
        object.biblio&.isbn
      end

      def receiver_library
        object.receiver_library.as_json(only: %i[id name code])
      end

      def sender_library
        object.sender_library.as_json(only: %i[id name code])
      end

      def transfer_order_status
        object.transfer_order_status.admin_status
      end

    end
  end
end

# frozen_string_literal: true

module Lms
  module Entities
    class LibraryTransferOrders < Grape::Entity
      expose :id
      expose :receiver_library
      expose :sender_library
      expose :order_type
      expose :transfer_order_status
      expose :created_at
      expose :return_at
      expose :reference_no
      expose :start_date
      expose :end_date
      expose :lto_line_items, using: Lms::Entities::LtoLineItems

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

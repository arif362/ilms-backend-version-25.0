# frozen_string_literal: true

module Admin
  module QueryParams
    module PurchaseOrderParams
      extend ::Grape::API::Helpers

      params :purchase_order_create_params do
        requires :po_line_item_params, type: Array do
          requires :publisher_biblio_id, type: Integer, allow_blank: false
          requires :quantity, type: Integer, allow_blank: false
          requires :price, type: Float, allow_blank: false
        end
        requires :memorandum_id, type: Integer, allow_blank: false
        requires :publisher_id, type: Integer, allow_blank: false
        requires :last_submission_date, type: DateTime, allow_blank: false
      end

      params :purchase_order_update_params do
        requires :po_line_item_params, type: Array do
          requires :publisher_biblio_id, type: Integer, allow_blank: false
          requires :quantity, type: Integer, allow_blank: false
          requires :price, type: Float, allow_blank: false
        end
        requires :memorandum_id, type: Integer, allow_blank: false
        requires :publisher_id, type: Integer, allow_blank: false
        requires :last_submission_date, type: DateTime, allow_blank: false
      end

      params :purchase_order_status_update_params do
        requires :status, type: String, allow_blank: false, values: PurchaseOrderStatus::STATUS_EXCEPT_RECEIVED
      end

      params :purchase_order_received_params do
        requires :po_line_item_params, type: Array do
          requires :po_line_item_id, type: Integer, allow_blank: false
          requires :quantity, type: Integer, allow_blank: false
        end
        optional :memorandum_id, type: Integer, allow_blank: false
      end

    end
  end
end

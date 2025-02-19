# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Admin
  class PoStatusValidation
    include Interactor

    delegate :purchase_order, :status, to: :context

    def call
      validate_purchase_order(purchase_order, status)
    end

    private
    def validate_purchase_order(purchase_order, status)
      return if status == 'cancelled' && !purchase_order.purchase_order_status.received?

      if purchase_order.purchase_order_status.pending? && status != 'approved'
        context.fail!(error: 'unable to change status, please approve it first')
      end

      if purchase_order.purchase_order_status.approved? && status != 'sent'
        context.fail!(error: "Cannot change status from approved to #{status} please send it first")
      end

      if purchase_order.purchase_order_status.received? || purchase_order.purchase_order_status.cancelled?
        context.fail!(error: "Purchase Order status #{purchase_order.purchase_order_status.publisher_status}, further status update is not possible")
      end
    end
  end
end

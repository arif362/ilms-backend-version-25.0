# frozen_string_literal: true

module PublicLibrary
  module Entities
    class ReturnOrder < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :id
      expose :created_at
      expose :order_items
      expose :status
      expose :return_type
      expose :invoice

      def order_items
        PublicLibrary::Entities::OrderItems.represent(object.return_items, locale: options[:locale], request_source: options[:request_source])
      end

      def status
        object.return_status.patron_status
      end

      def invoice
        invoice = object&.invoices&.last
        {
          id: invoice&.id,
          invoice_type: invoice&.invoice_type
        }
      end
    end
  end
end

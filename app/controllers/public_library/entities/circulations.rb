module PublicLibrary
  module Entities
    class Circulations< Grape::Entity
      expose :id
      expose :return_at, as: :return_date
      expose :created_at, as: :issue_date
      expose :status
      expose :price
      expose :item_info
      expose :invoice


      def item_info
        PublicLibrary::Entities::OrderItems.represent(object.biblio_item, locale: options[:locale], request_source: options[:request_source])
      end

      def status
        locale == :en ? object.circulation_status.patron_status : object.circulation_status.bn_patron_status
      end

      def price
        object&.biblio_item&.price
      end

      def locale
        options[:locale]
      end

      def invoice
        invoice = object&.invoices&.last
        {
          invoice_id: invoice&.id,
          invoice_type: invoice&.invoice_type
        }
      end
    end
  end
end

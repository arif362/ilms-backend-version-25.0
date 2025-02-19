# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  module FinePayment
    class SendInvoice
      include Interactor

      delegate :invoice, to: :context

      def call
        send_invoice
      end

      private
      def user_able
        Staff.find_by(id: invoice.updated_by_id)
      end

      def access_token(library)
        data = Lms::AccessManagement.call(user_able:, library:)
        data[:token] if data.success?
      end

      def base_library
        invoice.invoiceable.library
      end

      def send_invoice
        library_base_url = "#{base_library.ip_address}/api/library"
        url = URI("#{library_base_url}/service/circulation/fine-entry")
        Rails.logger.info("action url: #{url}")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(base_library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump(invoice_params(invoice))
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("LMS api response: #{response}")
        LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                response,
                                user_able,
                                response[:error] != true)

      end

      def invoice_params(invoice)
        {
          biblio_item_id: invoice.invoiceable.biblio_item_id,
          member_id: invoice.user.member.id,
          invoice_id: invoice.id,
          amount: invoice.invoice_amount
        }
      end
    end
  end
end

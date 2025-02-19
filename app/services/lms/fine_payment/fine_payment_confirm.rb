# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  module FinePayment
    class FinePaymentConfirm
      include Interactor

      delegate :invoice, to: :context

      def call
        confirm_fine_payment
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

      def confirm_fine_payment
        invoice.payments&.each do |payment|
          library_base_url = "#{base_library.ip_address}/api/library"
          url = URI("#{library_base_url}/service/ils/payment/confirm")
          Rails.logger.info("action url: #{url}")
          https = Net::HTTP.new(url.host, url.port)
          https.use_ssl = library_base_url.start_with?('https')
          request = Net::HTTP::Post.new(url)
          request['Authorization'] = "Bearer #{access_token(base_library)}"
          request['Content-Type'] = 'application/json'
          request.body = JSON.dump(fine_payment_params(payment))
          response = https.request(request).read_body
          response = JSON.parse(response, symbolize_names: true)
          Rails.logger.info("LMS api response: #{response}")
          LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                  response,
                                  user_able,
                                  response[:error] != true)
        end

      end

      def fine_payment_params(payment)
        {
          title: invoice.invoiceable.biblio_item&.biblio&.title,
          author: authors,
          accession_number: invoice.invoiceable.biblio_item&.accession_no,
          invoice_id: invoice.id,
          patron_id: invoice&.user&.member.id,
          amount: invoice.invoice_amount,
          fine_type: invoice.invoiceable.is_a?(Circulation) ? 'loan' : invoice.invoiceable.status,
          status: invoice.invoice_status,
          fine_created: invoice.created_at.strftime('%Y-%m-%d'),
          payment_method: payment.payment_type,
          payment_date: payment.updated_at.strftime('%Y-%m-%d'),
          recieved_by: payment&.updated_by&.name
        }
      end

      def authors
        invoice.invoiceable.biblio_item&.biblio&.authors.map do |author|
          {
            id: author.id,
            first_name: author.first_name,
            middle_name: author.middle_name,
            last_name: author.last_name,
            date: author.created_at.strftime('%Y-%m-%d')
          }
        end
      end
    end
  end
end

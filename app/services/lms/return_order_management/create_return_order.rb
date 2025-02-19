# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  module ReturnOrderManagement
    class CreateReturnOrder
      include Interactor

      delegate :return_order, :user_able, to: :context

      def call
        create_return_order
      end

      private

      def access_token(library)
        data = Lms::AccessManagement.call(user_able:, library:)
        data[:token] if data.success?
      end

      def library_base_url
        "#{return_order.library.ip_address}/api/library"
      end

      def create_return_order
        url = URI("#{library_base_url}/service/ils/return/place/")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(return_order.library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump(return_order_params)
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("LMS login api request: #{request.body}")
        Rails.logger.info("LMS api response: #{response}")
        LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                response,
                                user_able,
                                response[:error] != true)
      end

      def return_order_params
        # patron_id represents member_id
        {
          accession_numbers: return_order.biblio_items.pluck(:accession_no),
          return_id: return_order.id,
          patron_id: return_order.user.member.id
        }
      end
    end
  end
end

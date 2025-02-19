# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  module OrderManage
    class CreateExtendRequest
      include Interactor

      delegate :extend_request, :user_able, to: :context

      def call
        create_extend_request
      end

      private

      def access_token(library)
        data = Lms::AccessManagement.call(user_able:, library:)
        data[:token] if data.success?
      end

      def library_base_url
        "#{extend_request.library.ip_address}/api/library"
      end

      def create_extend_request
        url = URI("#{library_base_url}/service/loan/extend/")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(extend_request.library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump(extend_request_params)
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("LMS login api request: #{request.body}")
        Rails.logger.info("LMS api response: #{response}")
        LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                response,
                                user_able,
                                response[:error] != true)
      end

      def extend_request_params
        extend_request.order_id.present? ? common_params.merge!(order_id: extend_request.order_id) : common_params
      end

      def common_params
        {
          member_id: extend_request.member_id,
          accession_numbers: [extend_request.circulation.biblio_item.accession_no]
        }
      end
    end
  end
end

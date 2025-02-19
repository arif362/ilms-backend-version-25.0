# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  module ReturnOrderManagement
    class RoTransitStatusUpdate
      include Interactor

      delegate :return_order, :user_able, to: :context

      def call
        ro_transit_status_update
      end

      private

      def access_token(library)
        data = Lms::AccessManagement.call(user_able:, library:)
        data[:token] if data.success?
      end

      def library_base_url
        "#{return_order.library.ip_address}/api/library"
      end

      def ro_transit_status_update
        return unless return_order.library.working_url?(return_order.library.ip_address)

        url = URI("#{library_base_url}/service/ils/return/transit/#{return_order.id}")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(return_order.library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump({})
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("LMS login api request: #{request.body}")
        Rails.logger.info("LMS api response: #{response}")
        LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                response,
                                user_able,
                                response[:error] != true)
      end
    end
  end
end

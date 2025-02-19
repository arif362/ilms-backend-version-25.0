# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  module CardPrintManagement
    class IncomingStatusUpdate
      include Interactor

      delegate :library_card, :status, :user_able, to: :context

      def call
        incoming_status_update
      end

      private

      def access_token(library)
        data = Lms::AccessManagement.call(user_able:, library:)
        data[:token] if data.success?
      end

      def library_base_url
        "#{library_card.printing_library.ip_address}/api/library"
      end

      def incoming_status_update
        url = URI("#{library_base_url}/service/print/request/incoming/status-update")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(library_card.printing_library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump({ ils_library_card_id: library_card.id, status: status })
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

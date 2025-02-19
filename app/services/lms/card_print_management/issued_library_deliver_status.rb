# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  module CardPrintManagement
    class IssuedLibraryDeliverStatus
      include Interactor

      delegate :library_card, :user_able, to: :context

      def call
        deliver_status_update
      end

      private

      def access_token(library)
        data = Lms::AccessManagement.call(user_able:, library:)
        data[:token] if data.success?
      end

      def library_base_url
        "#{library_card.issued_library.ip_address}/api/library"
      end

      def deliver_status_update
        url = URI("#{library_base_url}/service/print/request/delivered")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(library_card.issued_library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump({ ils_library_card_id: library_card.id })
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

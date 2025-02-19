# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  class UpdateCardStatus
    include Interactor

    delegate :patron, :status, :user_able, to: :context

    def call
      update_card_status
    end

    private

    def access_token(library)
      data = Lms::AccessManagement.call(user_able:, library:)
      data[:token] if data.success?
    end

    def library_base_url
      "#{card.issued_library.ip_address}/api/library"
    end

    def update_card_status
      url = URI("#{library_base_url}/service/patron/card/status-update")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = library_base_url.start_with?('https')
      request = Net::HTTP::Post.new(url)
      request['Authorization'] = "Bearer #{access_token(card.issued_library)}"
      request['Content-Type'] = 'application/json'
      request.body = JSON.dump(card_status_params)
      response = https.request(request).read_body
      response = JSON.parse(response, symbolize_names: true)
      Rails.logger.info("LMS login api request: #{request.body}")
      Rails.logger.info("LMS api response: #{response}")
      LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                              response,
                              user_able,
                              response[:error] != true)
    end

    def card_status_params
      {
        patron_id: patron.id,
        status:
      }
    end
  end
end

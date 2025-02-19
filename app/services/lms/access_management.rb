# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  class AccessManagement
    include Interactor

    delegate :user_able, :library, to: :context

    def call
      access_token
    end

    private

    def library_base_url
      "#{library.ip_address}/api/library"
    end

    def access_token
      url = URI("#{library_base_url}/getServiceToken")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = library_base_url.start_with?('https')
      request = Net::HTTP::Post.new(url)
      request['Content-Type'] = 'application/json'
      request.body = JSON.dump({ service_code: (ENV['LMS_SERVICE_CODE']).to_s, pass_key: (ENV['LMS_PASS_KEY']).to_s })
      response = https.request(request).read_body
      response = JSON.parse(response, symbolize_names: true)
      Rails.logger.info("LMS login api response: #{response}")
      context.token = response[:data][:service_token]
      # LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
      #                         response,
      #                         user_able,
      #                         response[:error] != true)
    end
  end
end

# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  class CreateSecurityMoney
    include Interactor

    delegate :payment, :user_able, to: :context

    def call
      create_security_money
    end

    private

    def access_token(library)
      data = Lms::AccessManagement.call(user_able:, library:)
      data[:token] if data.success?
    end

    def library_base_url
      "#{payment.user.member.library.ip_address}/api/library"
    end

    def create_security_money
      url = URI("#{library_base_url}/service/patron/security-money/entry")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = library_base_url.start_with?('https')
      request = Net::HTTP::Post.new(url)
      request['Authorization'] = "Bearer #{access_token(payment&.user&.member&.library)}"
      request['Content-Type'] = 'application/json'
      request.body = JSON.dump(security_money_params)
      response = https.request(request).read_body
      response = JSON.parse(response, symbolize_names: true)
      Rails.logger.info("LMS login api request: #{request.body}")
      Rails.logger.info("LMS api response: #{response}")
      LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                              response,
                              user_able,
                              response[:error] != true)
    end

    def security_money_params
      {
        phone: payment&.user&.phone,
        payment_method: 'nagad',
        library_card_id: payment&.user&.member&.library_cards&.last&.id,
        member_id: payment&.user&.member&.id,
        ref_id: payment.user.membership_requests.last.id,
        amount: payment&.amount
      }
    end
  end
end

# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  module SecurityMoneyWithdrawalManage
    class UpdateSecurityMoneyWithdraw
      include Interactor

      delegate :request_details, :user_able, to: :context

      def call
        update_security_money_withdraw
      end

      private

      def access_token(library)
        data = Lms::AccessManagement.call(user_able:, library:)
        data[:token] if data.success?
      end

      def library_base_url
        "#{request_details.library.ip_address}/api/library"
      end

      def update_security_money_withdraw
        url = URI("#{library_base_url}/service/security-money-withdraw/update-status")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(request_details.library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump({ils_w_id: request_details.id,
                                  status: 'withdrawn'})
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

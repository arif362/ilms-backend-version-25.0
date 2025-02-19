# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  module SecurityMoneyWithdrawalManage
    class CreateSecurityMoneyWithdraw
      include Interactor

      delegate :request_details, :user_able, to: :context

      def call
        create_security_money_withdraw
      end

      private

      def access_token(library)
        data = Lms::AccessManagement.call(user_able:, library:)
        data[:token] if data.success?
      end

      def library_base_url
        "#{request_details.library.ip_address}/api/library"
      end

      def create_security_money_withdraw
        url = URI("#{library_base_url}/service/security-money-withdraw/request")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(request_details.library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump(security_money_withdraw_params)
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("--LMS login api request: #{request.body}--")
        Rails.logger.info("--LMS login api response: #{response}--")
        LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                response,
                                user_able,
                                response[:error] != true)
      end

      def security_money_withdraw_params
        {
          ils_w_id: request_details.id,
          ref_mid: request_details.user.member.id,
          payment_method: request_details.pickup_from_library? ? 'cash' : 'digital',
          amount: request_details.amount
        }
      end
    end
  end
end

# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  module OrderManage
    class UpdatePayStatusOrder
      include Interactor

      delegate :order, to: :context

      def call
        update_order
      end

      private

      def access_token(library)
        data = Lms::AccessManagement.call(user_able: order.user, library:)
        data[:token] if data.success?
      end

      def library_base_url
        "#{order.library.ip_address}/api/library"
      end

      def update_order
        return unless order.library.working_url?(order.library.ip_address)

        url = URI("#{library_base_url}/service/ils/order/paid/#{order.id}")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(order.library)}"
        request['Content-Type'] = 'application/json'
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("LMS login api request: #{request.body}")
        Rails.logger.info("LMS api response: #{response}")
        LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                response,
                                order.user,
                                response[:error] != true)

      end
    end
  end
end

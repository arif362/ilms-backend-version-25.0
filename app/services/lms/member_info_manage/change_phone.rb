# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  module MemberInfoManage
    class ChangePhone
      include Interactor

      delegate :user, to: :context

      def call
        change_member_phone
      end

      private

      def access_token(library)
        data = Lms::AccessManagement.call(user_able: user, library:)
        data[:token] if data.success?
      end

      def library_base_url
        "#{member.library.ip_address}/api/library"
      end

      def change_member_phone
        url = URI("#{library_base_url}/service/patron/update/phone/#{member.id}")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(member.library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump({ phone: user.phone })
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("LMS login api request: #{request.body}")
        Rails.logger.info("LMS api response: #{response}")
        LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                response,
                                user,
                                response[:error] != true)
      end

      def member
        user.member
      end
    end
  end
end

# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  module InterLibraryTransferManage
    class UpdateIntLibExtension
      include Interactor

      delegate :ile, :user_able, to: :context

      def call
        update_int_lib_extension
      end

      private

      def access_token(library)
        data = Lms::AccessManagement.call(user_able:, library:)
        data[:token] if data.success?
      end

      def library_base_url
        "#{ile.receiver_library.ip_address}/api/library"
      end

      def update_int_lib_extension
        url = URI("#{library_base_url}/service/library/borrower/extend/request-update/book/#{ile.library_transfer_order.transferable.id}")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(ile.receiver_library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump({ extension_status: ile.status })
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

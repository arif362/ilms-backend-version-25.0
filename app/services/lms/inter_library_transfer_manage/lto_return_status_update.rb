# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  module InterLibraryTransferManage
    class LtoReturnStatusUpdate
      include Interactor

      delegate :lto, :status, :library_type, :user_able, to: :context

      def call
        lto_return_status_update
      end

      private

      def access_token(library)
        data = Lms::AccessManagement.call(user_able:, library:)
        data[:token] if data.success?
      end

      def library_base_url
        "#{library.ip_address}/api/library"
      end

      def lto_return_status_update
        url = URI("#{library_base_url}/service/ils/interlibrary/return/update/#{lto.id}")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump(lto_return_params)
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("LMS login api request: #{request.body}")
        Rails.logger.info("LMS api response: #{response}")
        LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                response,
                                user_able,
                                response[:error] != true)
      end


      def lto_return_params
        status == 'in_transit' ? { status: }.merge(notes: lto.reference_no) : { status: }
      end

      def library
        library_type == 'sender' ? lto.sender_library : lto.receiver_library
      end
    end
  end
end

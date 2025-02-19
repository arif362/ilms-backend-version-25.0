# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  module InterLibraryTransferManage
    class LtoStatusUpdate
      include Interactor

      delegate :lto, :status, :library_type, :user_able, to: :context

      def call
        lto_status_update
      end

      private

      def access_token(library)
        data = Lms::AccessManagement.call(user_able:, library:)
        data[:token] if data.success?
      end

      def library_base_url
        "#{library.ip_address}/api/library"
      end

      def lto_status_update
        url = URI("#{library_base_url}/service/library/book/request/status-update")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump(lto_status_update_params)
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("LMS login api request: #{request.body}")
        Rails.logger.info("LMS api response: #{response}")
        LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                response,
                                user_able,
                                response[:error] != true)
      end

      def general_params
        {
          ref_id: lto.transferable.id,
          status:
        }
      end

      def lto_status_update_params
        if status == 'accepted'
          general_params.merge(accession_number: lto.lto_line_items.last.biblio_item.accession_no)
        else
          general_params.merge(notes: lto.reference_no)
        end
      end

      def library
        library_type == 'sender' ? lto.sender_library : lto.receiver_library
      end
    end
  end
end

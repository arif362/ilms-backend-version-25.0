# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  module InterLibraryTransferManage
    class CreateLtoReturn
      include Interactor

      delegate :lto_return, :user_able, to: :context

      def call
        create_lto_return
      end

      private

      def access_token(library)
        data = Lms::AccessManagement.call(user_able:, library:)
        data[:token] if data.success?
      end

      def library_base_url
        "#{lto_return.receiver_library.ip_address}/api/library"
      end

      def create_lto_return
        url = URI("#{library_base_url}/service/ils/interlibrary/return/place/")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(lto_return.receiver_library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump({accession_numbers: BiblioItem.where(id: lto_return.lto_line_items.pluck(:biblio_item_id)).pluck(:accession_no),
                                  return_id: lto_return.id})
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

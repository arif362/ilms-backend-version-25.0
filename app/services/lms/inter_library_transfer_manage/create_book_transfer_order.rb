# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  module InterLibraryTransferManage
    class CreateBookTransferOrder
      include Interactor

      delegate :request_details, :user_able, to: :context

      def call
        create_book_transfer_order
      end

      private

      def access_token(library)
        data = Lms::AccessManagement.call(user_able:, library:)
        data[:token] if data.success?
      end

      def library_base_url
        "#{request_details.library.ip_address}/api/library"
      end

      def create_book_transfer_order
        url = URI("#{library_base_url}/service/library/request/bymember")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(request_details.library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump(book_transfer_order_params)
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("LMS login api request: #{request.body}")
        Rails.logger.info("LMS api response: #{response}")
        LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                response,
                                user_able,
                                response[:error] != true)
      end

      def book_transfer_order_params
        member_type = request_details.user.member.present? ? 'member' : 'registered'

        {
          member_request_order_id: request_details.id,
          requested_member_id: member_type == 'member' ? request_details.user.member.id : request_details.user.id,
          patron_info: Lms::Entities::Patrons.represent(request_details.user),
          member_type:,
          bibliographic_id: request_details.biblio_id,
          bibliographic_info: Lms::Entities::BiblioDetails.represent(request_details.biblio)
        }
      end
    end
  end
end

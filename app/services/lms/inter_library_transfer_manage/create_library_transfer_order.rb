# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  module InterLibraryTransferManage
    class CreateLibraryTransferOrder
      include Interactor

      delegate :lto, :user_able, to: :context

      def call
        create_library_transfer_order
      end

      private

      def access_token(library)
        data = Lms::AccessManagement.call(user_able:, library:)
        data[:token] if data.success?
      end

      def library_base_url
        "#{lto.sender_library.ip_address}/api/library"
      end

      def create_library_transfer_order
        url = URI("#{library_base_url}/service/library/request/incoming/book")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(lto.sender_library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump(lto_create_params)
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("LMS login api request: #{request.body}")
        Rails.logger.info("LMS api response: #{response}")
        LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                response,
                                user_able,
                                response[:error] != true)
      end

      def lto_create_params
        member_type = lto.user.member.present? ? 'member' : 'registered'
        {
          ref_id: lto.transferable.id,
          from_library_id: lto.receiver_library.id,
          borrow_start_date: lto.start_date.strftime('%Y-%m-%d'),
          borrow_end_date: lto.end_date.strftime('%Y-%m-%d'),
          requested_member_id: member_type == 'member' ? lto.user.member.id : lto.user_id,
          member_type:,
          patron_info: Lms::Entities::Patrons.represent(lto.user),
          bibliographic_id: lto.lto_line_items.first.biblio_id
        }
      end
    end
  end
end

# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  module CardPrintManagement
    include Lms::Helpers::ImageHelpers
    class CreateCardPrint
      include Interactor

      delegate :library_card, :user_able, to: :context

      def call
        create_card_print
      end

      private

      def access_token(library)
        data = Lms::AccessManagement.call(user_able:, library:)
        data[:token] if data.success?
      end

      def library_base_url
        "#{library_card.printing_library.ip_address}/api/library"
      end

      def create_card_print
        url = URI("#{library_base_url}/service/print/request/incoming")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(library_card.printing_library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump(library_card_params)
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("LMS login api request: #{request.body}")
        Rails.logger.info("LMS api response: #{response}")
        LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                response,
                                user_able,
                                response[:error] != true)
      end

      def library_card_params
        # image_url = image_path(library_card_service.issued_library.staffs.library_head.authorized_signature)
        {
          ils_library_card_id: library_card.id,
          sender_library_id: library_card.issued_library_id,
          patron_name: library_card.name,
          branch_name: library_card.issued_library.name,
          member_type: library_card.member.membership_category,
          contact_address: library_card.issued_library.address,
          contact_email: library_card.issued_library.email,
          contact_web: 'http://public-library-web',
          issue_date: library_card.issue_date,
          expiration_date: library_card.expire_date
          # authorized_signature: library_card_service.issued_library.staffs.library_head.authorized_signature.attach(io: URI.open(image_url), filename: 'th.jpeg')
        }
      end
    end
  end
end

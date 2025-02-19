# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  module CardManage
    class CardReapply
      include Interactor

      delegate :library_card, to: :context

      def call
        card_reapply
      end

      private

      def access_token(library)
        data = Lms::AccessManagement.call(user_able: member.user, library:)
        data[:token] if data.success?
      end

      def library_base_url
        "#{member.library.ip_address}/api/library"
      end

      def card_reapply
        url = URI("#{library_base_url}/service/patron/card/request")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(member.library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump(card_reapply_params)
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("LMS api request: #{request.body}")
        Rails.logger.info("LMS api response: #{response}")
        LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                response,
                                user,
                                response[:error] != true)
      end

      def card_reapply_params
        {
          member_id: member.id,
          library_card_id: library_card.id,
          request_reason: reapply_reason,
          amount: ENV['LOST_CARD_AMOUNT'],
          supporting_documents: library_card.is_lost == true ? library_card.gd_image : library_card.damaged_card_image
        }
      end

      def reapply_reason
        'renew' if library_card.is_expired == true
        'lost' if  library_card.is_lost == true
        'damaged' if library_card.is_damaged == true
      end

      def member
        library_card.member
      end
    end
  end
end

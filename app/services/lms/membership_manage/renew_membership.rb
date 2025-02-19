# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  module MembershipManage
    class RenewMembership
      include Interactor

      delegate :membership_request, :user_able, to: :context

      def call
        renew_membership_request
      end

      private

      def access_token(library)
        data = Lms::AccessManagement.call(user_able:, library:)
        data[:token] if data.success?
      end

      def library_base_url
        "#{membership_request.request_detail.library.ip_address}/api/library"
      end

      def renew_membership_request
        url = URI("#{library_base_url}/service/patron/member-request")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(membership_request.request_detail.library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump(membership_request_params)
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("LMS membership request api response: #{response}")
        LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                response,
                                user_able,
                                response[:error] != true)
      end

      def request_detail
        membership_request.request_detail
      end

      def membership_request_params
        {
          phone: request_detail.phone,
          category: BorrowPolicy.categories[request_detail.membership_category],
          profile_image: membership_request.user.image&.url,
          father_name: request_detail.father_Name,
          mother_name: request_detail.mother_name,
          nid_birth_no: request_detail.identity_number,
          profession: request_detail.profession,
          institution_name: request_detail.institute_name,
          present_address: request_detail.present_address,
          permanent_address: request_detail.permanent_address,
          document_type: request_detail.identity_type
          # document: request_detail.,
        }
      end
    end
  end
end

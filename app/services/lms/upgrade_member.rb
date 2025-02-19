# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  class UpgradeMember
    include Interactor

    delegate :request_detail, :user_identity, :user_able, to: :context

    def call
      upgrade_member
    end

    private

    def access_token(library)
      data = Lms::AccessManagement.call(user_able: request_detail, library:)
      data[:token] if data.success?
    end

    def library_base_url
      "#{request_detail.library.ip_address}/api/library"
    end

    def upgrade_member

      url = URI("#{library_base_url}/service/patron/membership-upgrade")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = library_base_url.start_with?('https')
      request = Net::HTTP::Post.new(url)
      request['Authorization'] = "Bearer #{access_token(request_detail.library)}"
      request['Content-Type'] = 'application/json'
      request.body = JSON.dump(upgrade_params)
      response = https.request(request).read_body
      response = JSON.parse(response, symbolize_names: true)
      puts "LMS login api response: #{response}"
      Rails.logger.info("LMS api response: #{response}")
      LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                              response,
                              user_able,
                              response[:error] != true)
    end

    def upgrade_params
      {
        membership_upgrade_id: request_detail&.membership_request&.id,
        member_id: request_detail&.membership_request&.user&.member&.id,
        category: request_detail&.membership_category,
        identity_number: request_detail&.identity_number,
        institution_name: request_detail&.institute_name,
        institute_address: request_detail&.institute_address,
        profession: request_detail&.profession,
        phone: request_detail&.reload&.phone,
        amount: amount_calculation,
        documents: nil
      }
    end

    def amount_calculation
      if request_detail.membership_category == 'general'
        ENV['GENERAL_MBR_SECURITY_MONEY']
      elsif request_detail.membership_category == 'student'
        ['STUDENT_MBR_SECURITY_MONEY']
      end
    end
  end
end

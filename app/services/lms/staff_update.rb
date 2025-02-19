# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  class StaffUpdate
    include Interactor

    delegate :staff, to: :context

    def call
      update_staff
    end

    private

    def access_token(library)
      data = Lms::AccessManagement.call(staff:, library:)
      data[:token] if data.success?
    end

    def base_library
      staff.library
    end

    def update_staff
      return unless base_library.working_url?(base_library.ip_address)

      library_base_url = "#{base_library.ip_address}/api/library"
      url = URI("#{library_base_url}/service/staff/update/#{staff.id}")
      Rails.logger.info("action url: #{url}")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = library_base_url.start_with?('https')
      request = Net::HTTP::Post.new(url)
      request['Authorization'] = "Bearer #{access_token(base_library)}"
      request['Content-Type'] = 'application/json'
      request.body = JSON.dump(staff_params)
      response = https.request(request).read_body
      response = JSON.parse(response, symbolize_names: true)
      Rails.logger.info("LMS api response: #{response}")
      LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                              response,
                              staff,
                              response[:error] != true)
    end

    def staff_params
      {
        email: staff.email,
        phone: staff.phone,
        user_name: staff.email,
        name: staff.name,
        gender: staff.gender,
        category: 0
      }
    end
  end
end

# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Admin
  class StaffDeactivate
    include Interactor
    include PublicLibrary::Helpers::ImageHelpers

    delegate :staff, to: :context

    def call
      deactivate_staff
    end

    private
    def user_able
      Staff.find_by(id: staff.updated_by_id)
    end


    def access_token(library)
      data = Lms::AccessManagement.call(user_able:, library:)
      data[:token] if data.success?
    end

    def base_library
      staff.library
    end

    def deactivate_staff
      return unless base_library.working_url?(base_library.ip_address)

      library_base_url = "#{base_library.ip_address}/api/library"
      url = URI("#{library_base_url}/service/staff/deactivate/#{staff.id}")
      Rails.logger.info("action url: #{url}")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = library_base_url.start_with?('https')
      request = Net::HTTP::Post.new(url)
      request['Authorization'] = "Bearer #{access_token(base_library)}"
      request['Content-Type'] = 'application/json'
      request.body = ''
      response = https.request(request).read_body
      response = JSON.parse(response, symbolize_names: true)
      Rails.logger.info("LMS api response: #{response}")
      LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                              response,
                              user_able,
                              response[:error] != true)

    end
  end
end

# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  class Locations
    include Interactor
    include PublicLibrary::Helpers::ImageHelpers

    delegate :location, :action_type, to: :context

    def call
      create_location
    end

    private
    def user_able
      staff_id = action_type == 'created' ? location.created_by_id : location.updated_by_id
      Staff.library.find_by(id: staff_id)
    end

    def access_token(library)
      data = Lms::AccessManagement.call(user_able:, library:)
      data[:token] if data.success?
    end

    def base_library
      user_able.library
    end
    def create_location
      Library.where.not(id: base_library.id)&.each do |library|
        next unless library.working_url?(library.ip_address)

        library_base_url = "#{library.ip_address}/api/library"
        url = action_type == 'created' ? URI("#{library_base_url}/service/location") : URI("#{library_base_url}/service/location/#{location.id}")
        Rails.logger.info("action url: #{location.id}")
        Rails.logger.info("action url: #{url}")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = action_type == 'created' ? Net::HTTP::Post.new(url) : Net::HTTP::Put.new(url)
        request['Authorization'] = "Bearer #{access_token(library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump(location_params)
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("LMS api response: #{response}")
        LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                response,
                                user_able,
                                response[:error] != true)
      end
    end


    def location_params
      {
        ref_id: location.id,
        type: location.location_type,
        name: location.name
      }
    end
  end
end

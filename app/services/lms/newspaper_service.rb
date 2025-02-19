# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  class NewspaperService
    include Interactor

    delegate :newspaper, to: :context

    def call
      create_newspaper
    end

    private
    def user_able
      Staff.library.find_by(id: newspaper.created_by)
    end

    def access_token(library)
      data = Lms::AccessManagement.call(user_able:, library:)
      data[:token] if data.success?
    end

    def create_newspaper
      Library.all.each do |library|
        next unless library.working_url?(library.ip_address)

        library_base_url = "#{library.ip_address}/api/library"
        url = URI("#{library_base_url}/service/newspaper/create")
        Rails.logger.info("action url: #{url}")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump(newspaper_params)
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("LMS api response: #{response}")
        LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                response,
                                user_able,
                                response[:error] != true)
      end
    end

    def newspaper_params
      {
        ref_id: newspaper.id,
        name: newspaper.name,
        slug: newspaper.slug,
        category: newspaper.category,
        language: newspaper.language
      }
    end
  end
end

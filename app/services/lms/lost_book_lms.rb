# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  class LostBookLms
    include Interactor

    delegate :circulation, to: :context

    def call
      update_circulation
    end

    private

    def access_token(library)
      data = Lms::AccessManagement.call(user_able:, library:)
      data[:token] if data.success?
    end

    def base_library
      circulation.library
    end

    def user_able
      circulation.member.user
    end

    def update_circulation
      return unless base_library.working_url?(base_library.ip_address)

      library_base_url = "#{base_library.ip_address}/api/library"
      url = URI("#{library_base_url}/service/loan/lost/")
      Rails.logger.info("action url: #{url}")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = library_base_url.start_with?('https')
      request = Net::HTTP::Post.new(url)
      request['Authorization'] = "Bearer #{access_token(base_library)}"
      request['Content-Type'] = 'application/json'
      request.body = JSON.dump(circulation_params)
      response = https.request(request).read_body
      response = JSON.parse(response, symbolize_names: true)
      Rails.logger.info("LMS api response: #{response}")
      LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                              response,
                              user_able,
                              response[:error] != true)
    end

    def circulation_params
      {
        order_id: circulation.order_id,
        member_id: circulation.member_id,
        accession_number: circulation.biblio_item.accession_no
      }
    end
  end
end

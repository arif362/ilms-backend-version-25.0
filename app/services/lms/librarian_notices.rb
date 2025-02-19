# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  class LibrarianNotices
    include Interactor

    delegate :notice, to: :context

    def call
      create_notice
    end

    private
    def user_able
      Staff.library.find_by(id: notice.created_by_id)
    end

    def access_token(library)
      data = Lms::AccessManagement.call(user_able:, library:)
      data[:token] if data.success?
    end

    def create_notice
      Library.all.each do |library|
        next unless library.working_url?(library.ip_address)

        library_base_url = "#{library.ip_address}/api/library"
        url = URI("#{library_base_url}/service/notice/store")
        Rails.logger.info("action url: #{url}")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump(notice_params)
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("LMS api response: #{response}")
        LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                response,
                                user_able,
                                response[:error] != true)
      end
    end

    def notice_params
      {
        ref_id: notice.id,
        title: notice.title,
        bn_title: notice.bn_title,
        description: notice.description,
        bn_description: notice.bn_description,
        is_published: notice.is_published,
        document_file: ''
      }
    end
  end
end

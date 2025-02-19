# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  class Authors
    include Interactor
    include PublicLibrary::Helpers::ImageHelpers

    delegate :author, :action_type, to: :context

    def call
      create_author
    end

    private
    def user_able
      staff_id = action_type == 'created' ? author.created_by_id : author.updated_by_id
      Staff.library.find_by(id: staff_id)
    end

    def access_token(library)
      data = Lms::AccessManagement.call(user_able:, library:)
      data[:token] if data.success?
    end

    def base_library
      user_able.library
    end

    def create_author
      Library.where.not(id: base_library.id)&.each do |library|
        next unless library.working_url?(library.ip_address)

        library_base_url = "#{library.ip_address}/api/library"
        url = action_type == 'created' ? URI("#{library_base_url}/service/author") : URI("#{library_base_url}/service/author/#{author.id}")
        Rails.logger.info("action url: #{author.id}")
        Rails.logger.info("action url: #{url}")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = action_type == 'created' ? Net::HTTP::Post.new(url) : Net::HTTP::Put.new(url)
        request['Authorization'] = "Bearer #{access_token(library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump(author_params)
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("LMS api response: #{response}")
        LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                response,
                                user_able,
                                response[:error] != true)
      end
    end


    def author_params
      {
        ref_id: author.id,
        first_name: author.first_name,
        bn_first_name: author.bn_first_name,
        middle_name: author.middle_name,
        bn_middle_name: author.bn_middle_name,
        last_name: author.last_name,
        bn_last_name: author.bn_last_name,
        dob: author.dob,
        dod: author.dod
      }
    end
  end
end

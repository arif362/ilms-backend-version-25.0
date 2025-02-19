# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  class PhysicalBookReviews
    include Interactor
    include PublicLibrary::Helpers::ImageHelpers

    delegate :physical_review, :action_type, to: :context

    def call
      create_physical_review
    end

    private
    # def user_able
    #   staff_id = action_type == 'created' ? physical_review.created_by_id : physical_review.updated_by_id
    #   Staff.library.find_by(id: staff_id)
    # end

    def access_token(library)
      data = Lms::AccessManagement.call(library:)
      data[:token] if data.success?
    end

    def base_library
      physical_review.library
    end

    def create_physical_review
      return unless base_library.working_url?(base_library.ip_address)

      library_base_url = "#{base_library.ip_address}/api/library"
      url = URI("#{library_base_url}/service/biblio/physical-book-review")
      Rails.logger.info("action url: #{physical_review.id}")
      Rails.logger.info("action url: #{url}")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = library_base_url.start_with?('https')
      request = Net::HTTP::Post.new(url)
      request['Authorization'] = "Bearer #{access_token(base_library)}"
      request['Content-Type'] = 'application/json'
      request.body = JSON.dump(physical_review_params)
      response = https.request(request).read_body
      response = JSON.parse(response, symbolize_names: true)
      Rails.logger.info("LMS api response: #{response}")
      LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                              response,
                              nil,
                              response[:error] != true)

    end

    def physical_review_params
      {
        user_id: physical_review.user.id,
        member_id: physical_review&.user&.member&.id,
        biblio_item_id: physical_review.biblio_item.id,
        phone: physical_review&.user&.phone,
        email: physical_review&.user&.email,
        full_name: physical_review&.user&.full_name,
        review_body: physical_review.review_body
      }
    end
  end
end

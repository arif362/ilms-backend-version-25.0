# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  class EventRegistrationService
    include Interactor
    include PublicLibrary::Helpers::ImageHelpers

    delegate :registered_event, :action_type, to: :context

    def call
      registered_event_create_update
    end

    private

    def access_token(library)
      data = Lms::AccessManagement.call(user_able:, library:)
      data[:token] if data.success?
    end

    def user_able
      User.find_by(id: registered_event.user_id)
    end

    def base_library
      Library.find_by(id: registered_event.library_id)
    end

    def registered_event_create_update
      return unless base_library.working_url?(base_library.ip_address)

      library_base_url = "#{base_library.ip_address}/api/library"
      url = URI("#{library_base_url}/service/event/registration") if action_type == 'created'
      Rails.logger.info("registered_event id: #{registered_event.id}")
      Rails.logger.info("action url: #{url}")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = library_base_url.start_with?('https')
      request = Net::HTTP::Post.new(url) if action_type == 'created'
      request['Authorization'] = "Bearer #{access_token(base_library)}"
      request['Content-Type'] = 'application/json'
      request.body = JSON.dump(registered_event_params)
      response = https.request(request).read_body
      response = JSON.parse(response, symbolize_names: true)
      Rails.logger.info("LMS api response: #{response}")
      LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                              response,
                              user_able,
                              response[:error] != true)


    end

    def registered_event_params
      {
        ref_id: registered_event.id,
        ils_registered_id: registered_event.id,
        event_ref_id: registered_event.event_id,
        name: registered_event.name,
        phone: registered_event.phone,
        email: registered_event.email,
        father_name: registered_event.father_name,
        mother_name: registered_event.mother_name,
        profession: registered_event.profession,
        address: registered_event.address,
        identity_type: registered_event.identity_type,
        identity_number: registered_event.identity_number,
        competition_name: registered_event.competition_name,
        participate_group: registered_event.participate_group,
        membership_category: User.find_by(id: registered_event.user_id)&.member&.membership_category

      }
    end
  end
end

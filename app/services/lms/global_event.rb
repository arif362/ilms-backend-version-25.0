# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  class GlobalEvent
    include Interactor
    include PublicLibrary::Helpers::ImageHelpers

    delegate :event, :action_type, to: :context

    def call
      create_global_event
    end

    private

    def user_able
      staff_id = action_type == 'created' ? event.created_by : event.updated_by
      Staff.find_by(id: staff_id)
    end

    def access_token(library)
      data = Lms::AccessManagement.call(user_able:, library:)
      data[:token] if data.success?
    end

    def library
      if event.is_local?
        event.libraries
      else
        Library.all
      end
    end

    def create_global_event
      library&.each do |library|
        next unless library.working_url?(library.ip_address)

        library_base_url = "#{library.ip_address}/api/library"
        url = case action_type
              when 'created'
                URI("#{library_base_url}/service/event/store")
              when 'updated'
                URI("#{library_base_url}/service/event/update")
              when 'deleted'
                URI("#{library_base_url}/service/event/#{event.id}")
              end

        Rails.logger.info("action url: #{event.id}")
        Rails.logger.info("action url: #{url}")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = if action_type == 'created' || action_type == 'updated'
                    Net::HTTP::Post.new(url)
                  else
                    Net::HTTP::Delete.new(url)
                  end
        request['Authorization'] = "Bearer #{access_token(library)}"
        request['Content-Type'] = 'application/json'
        request.body = if action_type == 'created'
                         JSON.dump(event_lms_params)
                       elsif action_type == 'updated'
                         JSON.dump(event_lms_params)
                       end
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("LMS api response: #{response}")
        LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                response,
                                user_able,
                                response[:error] != true)
      end
    end

    def event_lms_params
      {
        ref_id: event.id,
        title: event.title,
        bn_title: event.bn_title,
        details: event.details,
        bn_details: event.bn_details,
        start_date: event.start_date.strftime('%Y-%m-%d'),
        end_date: event.end_date.strftime('%Y-%m-%d'),
        is_published: event.is_published,
        is_registerable: event.is_registerable,
        email: event.email,
        phone: event.phone,
        registration_last_date: event.registration_last_date.strftime('%Y-%m-%d'),
        registration_fields: event.registration_fields,
        competition_info: event.competition_info,
        image_file: image_path(event.image)

      }
    end
  end
end

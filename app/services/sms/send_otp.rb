require 'net/http'
require 'uri'
require 'rexml/document'

module Sms
  class SendOtp
    include Interactor

    delegate :phone, :message, to: :context

    MESSAGE_STATUS = {
      failed: -1,
      pending: 0,
      successful: 1,
      processing: 2,
    }.freeze

    def call
      context.phone = "88#{phone}" if phone.length == 11
      response = call_api
      context.fail!(error: response[:StatusText]) if response[:Status] == MESSAGE_STATUS[:failed]
    end

    def call_api
      url = URI.parse(URI::DEFAULT_PARSER.escape(api_url))
      response = Net::HTTP.get_response(url)
      actual_need = Hash.from_xml response.read_body.to_s
      result = actual_need['ArrayOfServiceClass']['ServiceClass']
      Rails.logger.info '<<<<<<<<<<<<<<<  Sms response from mobireach end started>>>>>>>>>>>>>>>>'
      Rails.logger.info "Sms response from mobireach: #{result}"
      Rails.logger.info '<<<<<<<<<<<<<<<<<<<<<<<<< Sms response from mobireach end >>>>>>>>>>>>>>>>>>>>>>>'
      result
    end

    private

    def api_url
      "#{ENV['MOBIREACH_API_URL']}?Username=#{ENV['MOBIREACH_API_USER_NAME']}&Password=#{ENV['MOBIREACH_API_PASSWORD']}&From=#{ENV['MOBIREACH_API_FROM']}&To=#{context.phone}&Message=#{message}"
    end
  end
end

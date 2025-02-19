# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  class CreateUser
    include Interactor
    include PublicLibrary::Helpers::ImageHelpers
    include Admin::Helpers::ImageHelpers

    delegate :request_detail, :user_identity, :user_able, to: :context

    def call
      create_user
    end

    private

    def access_token(library)
      data = Lms::AccessManagement.call(user_able: request_detail, library:)
      data[:token] if data.success?
    end

    def library_base_url
      "#{request_detail.library.ip_address}/api/library"
    end

    def create_user
      url = URI("#{library_base_url}/service/patron/register")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = library_base_url.start_with?('https')
      request = Net::HTTP::Post.new(url)
      request['Authorization'] = "Bearer #{access_token(request_detail.library)}"
      Rails.logger.info("....................................LMS api request: #{register_params}............................................")
      request.set_form register_params, 'multipart/form-data'
      response = https.request(request)

      Rails.logger.info(".................................................LMS api response: #{response.read_body}..............................")
    end

    def register_params
      if user_identity[:user_type] == 'staff'
        staff_params
      else
        patron_params
      end
    end

    def patron_params
      [
        ['category', BorrowPolicy.categories[request_detail.membership_category].to_s],
        ['name', request_detail.full_name || ''],
        ['user_name', request_detail.phone || ''],
        ['phone', request_detail.phone || ''],
        ['email', request_detail.email || ''],
        ['father_name', request_detail.father_Name || ''],
        ['mother_name', request_detail.mother_name || ''],
        ['dob', request_detail.dob.strftime('%Y-%m-%d') || ''],
        ['ref_id', request_detail.membership_request.user.id.to_s || ''],
        ['gender', request_detail.gender || ''],
        ['nid_birth_no', request_detail.identity_number || ''],
        ['profession', request_detail.profession || ''],
        ['institution_name', request_detail.institute_name || ''],
        ['present_address', request_detail.present_address || ''],
        ['permanent_address', request_detail.permanent_address || ''],
        ['identity_type', request_detail.identity_type || ''],
        ['identity_number', request_detail.identity_number || ''],
        ['student_id', request_detail.student_id || ''],
        ['membership_request_id', request_detail.membership_request.id.to_s || ''],
        ['profile_image',
         user_identity[:attachments][:profile_photo].present? ? File.open(user_identity[:attachments][:profile_photo]) : ''],
        ['nid_front_image_file',
         user_identity[:attachments][:nid_front_image_file].present? ? File.open(user_identity[:attachments][:nid_front_image_file]) : ''],
        ['nid_back_image_file',
         user_identity[:attachments][:nid_back_image_file].present? ? File.open(user_identity[:attachments][:nid_back_image_file]) : ''],
        ['student_id_image_file',
         user_identity[:attachments][:student_id_image_file].present? ? File.open(user_identity[:attachments][:student_id_image_file]) : ''],
        ['birth_certificate_image_file',
         user_identity[:attachments][:birth_certificate_image_file].present? ? File.open(user_identity[:attachments][:birth_certificate_image_file]) : ''],
      ]
    end

    def staff_params
      [
        ['category', '0'],
        ['staff_id', request_detail.id.to_s],
        ['ref_id', request_detail.id.to_s],
        ['user_name', request_detail.email],
        ['email', request_detail.email],
        ['name', request_detail.name],
        ['is_library_head', (request_detail.is_library_head.present? ? 1.to_s : 0.to_s)],
        ['password', user_identity[:password]],
        ['password_confirmation', user_identity[:password]],
        ['gender', request_detail.gender || 'male'],
        ['approved_designation', request_detail.designation.title || ''],
        ['staff_designation', request_detail.sanctioned_post || ''],
        ['profile_image', 
         user_identity[:attachments][:profile_photo].present? ? File.open(user_identity[:attachments][:profile_photo]) : ''],
        ['librarian_signature', 
         user_identity[:attachments][:signature].present? ? File.open(user_identity[:attachments][:signature]) : ''],
        ['dob', request_detail.dob.strftime('%Y-%m-%d')],
        ['phone', request_detail.phone || '']
      ]
    end
  end
end

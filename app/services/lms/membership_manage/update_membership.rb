# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'
require 'open-uri'

module Lms
  module MembershipManage
    class UpdateMembership
      include Interactor

      delegate :membership_request, :user_able, to: :context

      def call
        update_membership_request
      end

      private

      def access_token(library)
        data = Lms::AccessManagement.call(user_able:, library:)
        data[:token] if data.success?
      end

      def library_base_url
        "#{membership_request.request_detail.library.ip_address}/api/library"
      end

      def update_membership_request
        url = URI("#{library_base_url}/service/patron/update/#{membership_request.id}")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(membership_request.request_detail.library)}"
        request['Content-Type'] = 'multipart/form-data'
        request.body = JSON.dump(membership_request_params)
        response = https.request(request).read_body
        Rails.logger.info("-----before parse response---- #{response}")
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("-----after parse response---- #{response}")
        Rails.logger.info("LMS membership request api response: #{response}")
        LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                response,
                                user_able,
                                response[:error] != true)
      end

      def request_detail
        membership_request.request_detail
      end

      def membership_request_params
        {
          email: request_detail.email.present? ? request_detail.email : "lms_#{request_detail.membership_request&.user_id}@gmail.com",
          phone: request_detail.phone,
          user_name: request_detail.phone,
          name: request_detail.full_name,
          gender: request_detail.gender,
          profile_image: membership_request.user.image.download.force_encoding('UTF-8').scrub,
          father_name: request_detail.father_Name,
          mother_name: request_detail.mother_name,
          dob: request_detail.dob.strftime('%Y-%m-%d'),
          nid_birth_no: request_detail.identity_number,
          category: BorrowPolicy.categories[request_detail.membership_category],
          profession: request_detail.profession,
          institution_name: request_detail.institute_name,
          present_address: request_detail.present_address,
          permanent_address: request_detail.permanent_address,
          document_type: request_detail.identity_type,
          document: identity_image
        }
      end

      def identity_image
        image = request_detail.identity_type == 'nid' ? request_detail.nid_front_image : request_detail.birth_certificate_image

        # Send the file
        # file_content = open(image.url).read
        # send_data file_content, type: 'image/jpeg', disposition: 'inline', filename: "document.jpg"
        # io_object = StringIO.new(image.download)

        # Now you can use `io_object` as needed, for example, send it as a response
        # send_data io_object.read, filename: 'avatar.jpg', type: 'image/jpeg', disposition: 'inline'
        image.download.force_encoding('UTF-8').scrub
      end
    end
  end
end

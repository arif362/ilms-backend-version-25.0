# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  module OrderManage
    class CreateOrder
      include Interactor

      delegate :order, :user_able, to: :context

      def call
        create_order
      end

      private

      def access_token(library)
        data = Lms::AccessManagement.call(user_able: order.user, library:)
        data[:token] if data.success?
      end

      def library_base_url
        "#{order.library.ip_address}/api/library"
      end

      def create_order
        notifier_library_ids = order.pickup? ? [order.pick_up_library_id, order.library_id].uniq : [order.library_id]
        Library.where(id: notifier_library_ids)&.each do |library|
          next unless library.working_url?(library.ip_address)


          library_base_url = "#{library.ip_address}/api/library"
          url = if library.id == order.pick_up_library_id
                  if order.library_id == order.pick_up_library_id
                    URI("#{library_base_url}/service/ils/order/multiple")
                  else
                    URI("#{library_base_url}/service/ils/other/online/order/multiple")
                  end
                else
                  URI("#{library_base_url}/service/ils/order/multiple")
                end
          https = Net::HTTP.new(url.host, url.port)
          https.use_ssl = library_base_url.start_with?('https')
          request = Net::HTTP::Post.new(url)
          request['Authorization'] = "Bearer #{access_token(order.library)}"
          request['Content-Type'] = 'application/json'
          request.body = JSON.dump(order_params(library))
          response = https.request(request).read_body
          response = JSON.parse(response, symbolize_names: true)
          Rails.logger.info("LMS login api request: #{request.body}")
          Rails.logger.info("LMS api response: #{response}")
          LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                  response,
                                  user_able,
                                  response[:error] != true)
        end
      end

      def order_params(library)
        {
          bibliographic_ids: order.line_items.pluck(:biblio_id),
          order_id: order.id,
          patron_id: order.user&.member&.id,
          is_self_pickup: library.id == order.pick_up_library_id,
          is_remote_pickup: library.id != order.pick_up_library_id,
          patron_info: Lms::Entities::Patrons.represent(order.user),
          bibliographic_infos: Lms::Entities::BiblioDetails.represent(biblios)
        }
      end

      def biblios
        Biblio.where(id: order.line_items.map(&:biblio_id))
      end
    end
  end
end

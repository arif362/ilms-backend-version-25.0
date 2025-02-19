# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Lms
  module OrderManage
    class UpdateOrder
      include Interactor

      delegate :order, :user_able, to: :context

      def call
        update_order
      end

      private

      def access_token(library)
        data = Lms::AccessManagement.call(user_able: order.user, library:)
        data[:token] if data.success?
      end

      def base_library
        library_id = if %w[delivered_to_library delivered collected_by_3pl].include?(order.order_status.status_key)
                       order.library_id
                     else
                       order.pick_up_library_id || order.library_id
                     end
        Library.find_by(id: library_id)
      end

      def update_order

        return unless base_library.working_url?(base_library.ip_address)

        library_base_url = "#{base_library.ip_address}/api/library"
        Rails.logger.info("Request base url : #{library_base_url}")
        status_based_url = if order.order_status.order_confirmed?
                             "service/ils/other/online/confirm/status/#{order.id}"
                           elsif %w[delivered_to_library delivered collected_by_3pl].include?(order.order_status.status_key)
                             "service/ils/order/delivered/#{order.id}"
                           else
                             "service/ils/other/online/update/order/status/#{order.id}"
                           end


        Rails.logger.info("Request status url : #{status_based_url}")
        url = URI("#{library_base_url}/#{status_based_url}")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = library_base_url.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['Authorization'] = "Bearer #{access_token(base_library)}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump(order_params)
        Rails.logger.info("Request body : #{order_params}")
        response = https.request(request).read_body
        Rails.logger.info("Response body : #{response}")
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("LMS login api request: #{request.body}")
        Rails.logger.info("LMS api response: #{response}")
        LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                                response,
                                user_able,
                                response[:error] != true)

      end

      def order_params
        Rails.logger.info("Order status : #{order.order_status.status_key}")

        if order.order_status.order_confirmed?
          order_confirm_params
        else
          order_status_update_params
        end
      end

      def order_status_update_params
        {
          status: order.order_status.status_key
        }
      end

      def order_confirm_params
        {
          bibliographic_ids: order.line_items.map(&:biblio_id),
          accession_numbers: BiblioItem.where(id: order.line_items.map(&:biblio_item_id)).map(&:accession_no)
        }
      end

    end
  end
end

module ParcelManagement
  module Orders
    class UpdateParcel
      include Interactor

      delegate :order, to: :context

      def call
        cancel_parcel
      end

      private

      def cancel_parcel
        url = URI("#{ENV['REDEX_BASE_URL']}/v1.0.0-beta/parcel")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true if url.to_s.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['API-ACCESS-TOKEN'] = "Bearer #{ENV['API_ACCESS_TOKEN']}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump(update_parcel_params)
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("Redex login api request: #{response}")
      end

      def update_parcel_params
        {
          "entity_type": 'parcel-tracking-id',
          "entity_id": order.tracking_id,
          "update_details": {
            "property_name": 'status',
            "new_value": 'cancelled',
            "reason": order.note
          }
        }
      end
    end
  end
end

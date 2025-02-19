module ParcelManagement
  module Orders
    class CreateParcel
      include Interactor

      delegate :order, to: :context

      def call
        create_parcel
      end

      private

      def create_parcel
        url = URI("#{ENV['REDEX_BASE_URL']}/v1.0.0-beta/parcel")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true if url.to_s.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['API-ACCESS-TOKEN'] = "Bearer #{ENV['API_ACCESS_TOKEN']}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump(create_parcel_params)
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("Redex login api request: #{request.body}")
        Rails.logger.info("Redex login api response: #{response}")
        return unless response[:tracking_id].present?

        order.update_columns(tracking_id: response[:tracking_id])
      end

      def create_parcel_params
        {
          customer_name: order.user.full_name,
          customer_phone: order.recipient_phone,
          delivery_area: order.delivery_area,
          delivery_area_id: order.delivery_area_id,
          pickup_store_id: order.pickup_store_id,
          customer_address: order.address,
          merchant_invoice_id: order.invoices&.last&.id&.to_s,
          cash_collection_amount: order.invoices.last.invoice_amount,
          parcel_weight: 500,
          value: order.invoices.last.invoice_amount,
          is_closed_box: true,
          parcel_details_json: order.line_items.map do |item|
                                 {
                                   name: item.biblio.title,
                                   value: item.price
                                 }
                               end
        }
      end
    end
  end
end

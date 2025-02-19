module ParcelManagement
  module PickUpStores
    class CreatePickUpStore
      include Interactor

      delegate :library, to: :context

      def call
        create_pick_up_store
      end

      private

      def create_pick_up_store
        url = URI("#{ENV['REDEX_BASE_URL']}/v1.0.0-beta/pickup/store")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true if url.to_s.start_with?('https')
        request = Net::HTTP::Post.new(url)
        request['API-ACCESS-TOKEN'] = "Bearer #{ENV['API_ACCESS_TOKEN']}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.dump(store_params)
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("Redex login api request: #{request.body}")
        Rails.logger.info("Redex login api response: #{response}")
        return unless response[:id].present?

        library.update_columns(redx_pickup_store_id: response[:id])
      end

      def store_params
        {
          "name": library.name,
          "phone": library.phone,
          "address": library.address,
          "area_id": library.redx_area_id
        }
      end
    end
  end
end

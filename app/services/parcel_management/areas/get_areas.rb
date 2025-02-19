module ParcelManagement
  module Areas
    class GetAreas
      include Interactor

      delegate :post_code, :district_name, :zone_id, to: :context

      def call
        get_areas
      end

      private

      def get_areas
        url = URI("#{ENV['REDEX_BASE_URL']}/v1.0.0-beta/areas?district_name=#{district_name}")
        Rails.logger.info("Redex login api url: #{url}")

        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true if url.to_s.start_with?('https')
        request = Net::HTTP::Get.new(url)
        request['API-ACCESS-TOKEN'] = "Bearer #{ENV['API_ACCESS_TOKEN']}"
        request['Content-Type'] = 'application/json'
        # request.body = JSON.dump(area_filter_params)
        response = https.request(request).read_body
        response = JSON.parse(response, symbolize_names: true)
        Rails.logger.info("Redex login api request: #{ENV['API_ACCESS_TOKEN']}")
        Rails.logger.info("Redex login api request: #{request.body}")
        Rails.logger.info("Redex login api response: #{response}")
        context.areas = response[:areas]
      end

      def area_filter_params
        {
          post_code:,
          district_name:,
          zone_id:
        }
      end

    end
  end
end

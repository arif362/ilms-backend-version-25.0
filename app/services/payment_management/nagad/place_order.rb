module PaymentManagement
  module Nagad
    class PlaceOrder
      include Interactor

      delegate :invoice, :ip_address, :payment_reference_id, :challenge, :payment, to: :context

      def call
        url = URI("#{ENV['NAGAD_API_URL']}/api/dfs/check-out/complete/#{payment_reference_id}")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true if ENV['NAGAD_API_URL'].start_with?('https')
        header = PaymentManagement::Nagad.headers(ip_address)
        request = Net::HTTP::Post.new(url, header)
        request.body = request_body.to_json

        response = http.request(request)
        response_body = JSON.parse(response.read_body, symbolize_names: true)
        Rails.logger.info "Nagad Place invoice response for #{payment.id}: #{response_body}"
        if response_body[:callBackUrl].nil? && response_body[:reason].present?
          context.fail!(error: response_body[:message])
        end
        context.callback_url = response_body[:callBackUrl]
      end

      private

      def merchant_callback_url
        return "#{ENV['ROOT_URL']}/nagad-verify/#{invoice.id}" if Rails.env.production?
        return "#{ENV['ROOT_URL']}/nagad-verify/#{invoice.id}" if Rails.env.staging?

        "#{ENV['ROOT_URL']}/nagad-verify/#{invoice.id}"
      end

      def request_body
        {
          sensitiveData: sensitive_data,
          signature:,
          merchantCallbackURL: merchant_callback_url
        }
      end

      def invoice_id
        @invoice_id ||= invoice.backend_id
      end

      def payment_id
        @payment_id ||= payment.backend_id
      end

      def merchant_id
        @merchant_id ||= ENV['NAGAD_MERCHANT_ID']
      end

      def plain_sensitive_data
        {
          merchantId: merchant_id,
          orderId: payment_id,
          currencyCode: '050',
          amount: payment.amount,
          challenge:
        }
      end

      def sensitive_data
        PaymentManagement::Nagad.encoded_sensitive_data(plain_sensitive_data.to_json)
      end

      def signature
        PaymentManagement::Nagad.signature(plain_sensitive_data.to_json)
      end
    end
  end
end

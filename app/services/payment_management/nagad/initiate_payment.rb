module PaymentManagement
  module Nagad
    class InitiatePayment
      include Interactor

      delegate :invoice, :payment, :ip_address, to: :context

      def call
        Rails.logger.info "Sending Nagad intiaite request...."
        url = URI("#{ENV['NAGAD_API_URL']}/api/dfs/check-out/initialize/#{merchant_id}/#{payment_id}")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true if ENV['NAGAD_API_URL'].start_with?('https')
        header = PaymentManagement::Nagad.headers(ip_address)
        request = Net::HTTP::Post.new(url, header)
        request.body = request_body.to_json

        Rails.logger.info "Nagad request body #{request_body.to_json}"
        response = http.request(request)
        response_body = JSON.parse(response.read_body, symbolize_names: true)
        Rails.logger.info "Nagad Checkout Initialize Response for #{payment.id}: #{response_body}"
        Rails.logger.info "Nagad Server time: #{DateTime.now.in_time_zone('Dhaka').to_s(:number)}"
        decoded_response = decoded_response(response_body[:sensitiveData])
        context.payment_reference_id = decoded_response[:payment_reference_id]
        context.challenge = decoded_response[:challenge]
        Rails.logger.info "Intiaiting payment decoding Nagad response: #{decoded_response}"
      end

      private

      def request_body
        {
          dateTime: DateTime.now.in_time_zone('Dhaka').to_s(:number),
          sensitiveData: sensitive_data,
          signature: signature,
        }
      end

      def payment_id
        @payment_id ||= payment.backend_id
      end

      def merchant_id
        @merchant_id ||= ENV['NAGAD_MERCHANT_ID']
      end

      def challenge
        @challenge ||= SecureRandom.alphanumeric(40)
      end

      def plain_sensitive_data
        {
          merchantId: merchant_id,
          datetime: DateTime.now.in_time_zone('Dhaka').to_s(:number),
          orderId: payment_id,
          challenge: challenge,
        }
      end

      def sensitive_data
        PaymentManagement::Nagad.encoded_sensitive_data(plain_sensitive_data.to_json)
      end

      def signature
        PaymentManagement::Nagad.signature(plain_sensitive_data.to_json)
      end

      def decoded_response(sensitive_data)
        decoded_sensitive_data = JSON.parse(PaymentManagement::Nagad.decoded_sensitive_data(sensitive_data),
                                            symbolize_names: true)

        {
          payment_reference_id: decoded_sensitive_data[:paymentReferenceId],
          challenge: decoded_sensitive_data[:challenge]
        }
      end
    end
  end
end

module PaymentManagement
  module Nagad
    class VerifyPayment
      include Interactor

      delegate :payment, :ip_address, :payment_reference_id, to: :context

      def call
        url = URI("#{ENV['NAGAD_API_URL']}/api/dfs/verify/payment/#{payment_reference_id}")
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true if ENV['NAGAD_API_URL'].start_with?('https')
        header = PaymentManagement::Nagad.headers(ip_address)
        request = Net::HTTP::Get.new(url, header)
        response = http.request(request)
        response_body = JSON.parse(response.read_body, symbolize_names: true)
        Rails.logger.info "Verifying Nagad payment #{payment_reference_id}  for payment id #{payment.id}, response: #{response_body}"
        if response_body[:status] == 'Success'
          payment.update!(status: :success, trx_id: response_body[:issuerPaymentRefNo])
          payment.invoices.each do |invoice|
            invoice.invoiceable.paid! if invoice.invoiceable.is_a?(Order)
          end
          Rails.logger.info "Patron payment successfully paid invoice: #{payment.id}"
          context.redirect_url = success_url
        else
          Rails.logger.info "Patron payment failed for Nagad payment: #{payment.id} and payment_reference_id: #{payment_reference_id}"
          context.fail!(error: "Payment isn't successful.")
        end
      end

      def success_url
        return "#{ENV['ROOT_URL']}/invoice-success" if Rails.env.production?
        return "#{ENV['ROOT_URL']}/invoice-success" if Rails.env.staging?

        "#{ENV['ROOT_URL']}/invoice-success"
      end

      def failure_url
        return "#{ENV['ROOT_URL']}/invoice-failure" if Rails.env.production?
        return "#{ENV['ROOT_URL']}/invoice-failure" if Rails.env.staging?

        "#{ENV['ROOT_URL']}/invoice-failure"

      end
    end
  end
end

module PaymentManagement
  module Nagad
    def self.headers(ip_address)
      {
        'X-KM-IP-V4' => ip_address,
        'X-KM-Client-Type' => 'PC_WEB',
        'X-KM-Api-Version' => 'v-0.2.0',
        'Content-Type' => 'application/json'
      }
    end

    def self.public_key
      key = "-----BEGIN PUBLIC KEY-----\n#{ENV['NAGAD_PUBLIC_KEY']}\n-----END PUBLIC KEY-----\n"
      Rails.logger.info "Reading Nagad public: #{ENV['NAGAD_PUBLIC_KEY']}"
      OpenSSL::PKey::RSA.new(key)
    end

    def self.private_key
      key = "-----BEGIN PRIVATE KEY-----\n#{ENV['NAGAD_PRIVATE_KEY']}\n-----END PRIVATE KEY-----\n"
      Rails.logger.info "Reading Nagad private: #{ENV['NAGAD_PRIVATE_KEY']}"
      OpenSSL::PKey::RSA.new(key)
    end

    def self.encoded_base64(data)
      Base64.encode64(data).gsub(/\n/, '')
    end

    def self.decoded_base64(data)
      Rails.logger.info "Base64  decode64 data: #{data}"
      Base64.decode64(data)
    end

    def self.encoded_sensitive_data(plain_sensitive_data)
      Rails.logger.info "Nagad sensitive data: #{plain_sensitive_data}"
      encoded_base64(public_key.public_encrypt(plain_sensitive_data))
    end

    def self.decoded_sensitive_data(encoded_sensitive_data)
      Rails.logger.info "Nagad decoding sensitive data: #{encoded_sensitive_data}"
      private_key.private_decrypt(decoded_base64(encoded_sensitive_data))
    end

    def self.signature(plain_sensitive_data)
      Rails.logger.info "Nagad signature #{plain_sensitive_data}"
      encoded_base64(private_key.sign(OpenSSL::Digest.new('SHA256'), plain_sensitive_data))
    end

    class CompletePayment
      include Interactor::Organizer

      organize(
        PaymentManagement::CreatePaymentInstance,
        PaymentManagement::Nagad::InitiatePayment,
        PaymentManagement::Nagad::PlaceOrder
      )
    end
  end
end

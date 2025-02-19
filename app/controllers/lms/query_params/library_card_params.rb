# frozen_string_literal: true

module Lms
  module QueryParams
    module LibraryCardParams
      extend ::Grape::API::Helpers

      params :apply_card_params do
        requires :apply_reason, type: String, values: %w[lost damage renew], allow_blank: false
        requires :delivery_type, type: String, values: LibraryCard.delivery_types.keys, allow_blank: false
        requires :staff_id, type: Integer, allow_blank: false
        requires :is_self_recipient, type: Boolean, allow_blank: false
        optional :pay_type, type: String, values: LibraryCard.pay_types.keys, allow_blank: false
        optional :address_type, type: String, values: LibraryCard.address_types.keys, allow_blank: false
        optional :recipient_name, type: String, allow_blank: false
        optional :recipient_phone, type: String, allow_blank: false, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
        optional :delivery_address, type: String, allow_blank: false
        optional :division_id, type: Integer, allow_blank: false
        optional :district_id, type: Integer, allow_blank: false
        optional :thana_id, type: Integer, allow_blank: false
        optional :card_image_file, type: File
        optional :gd_image_file, type: File
        optional :save_address, type: Boolean
        optional :address_name, type: String
        optional :address, type: String
        optional :delivery_area_id, type: Integer
        optional :delivery_area, type: String
      end
    end
  end
end

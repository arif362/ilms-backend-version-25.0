# frozen_string_literal: true

module PublicLibrary
  module QueryParams
    module ReturnOrderParams
      extend ::Grape::API::Helpers
      params :return_create_params do
        requires :circulation_ids, type: Array, allow_blank: false
        requires :address_type, type: String, values: ReturnOrder.address_types.keys, allow_blank: false
        optional :division_id, type: Integer, allow_blank: false
        optional :district_id, type: Integer, allow_blank: false
        requires :thana_id, type: Integer, allow_blank: false
        optional :note, type: String, allow_blank: false
        optional :save_address, type: Boolean, allow_blank: false
        optional :address_name, type: String, allow_blank: false
        optional :address, type: String
        optional :recipient_name, type: String
        optional :recipient_phone, type: String, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
        optional :delivery_area, type: String
        optional :delivery_area_id, type: Integer
      end
    end
  end
end

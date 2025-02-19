# frozen_string_literal: true

module PublicLibrary
  module QueryParams
    module SavedAddressParams
      extend ::Grape::API::Helpers
      params :saved_address_create_params do
        requires :name, type: String, allow_blank: false
        requires :address, type: String, allow_blank: false
        requires :division_id, type: Integer, allow_blank: false
        requires :district_id, type: Integer, allow_blank: false
        requires :thana_id, type: Integer, allow_blank: false
        optional :recipient_name, type: String, allow_blank: false
        optional :recipient_phone, type: String, allow_blank: false
        requires :delivery_area_id, type: String, allow_blank: false
        requires :delivery_area, type: String, allow_blank: false
      end

      params :saved_address_update_params do
        requires :name, type: String, allow_blank: false
        requires :address, type: String, allow_blank: false
        requires :division_id, type: Integer, allow_blank: false
        requires :district_id, type: Integer, allow_blank: false
        requires :thana_id, type: Integer, allow_blank: false
        optional :recipient_name, type: String, allow_blank: false
        optional :recipient_phone, type: String, allow_blank: false
        requires :delivery_area_id, type: String, allow_blank: false
        requires :delivery_area, type: String, allow_blank: false
      end
    end
  end
end

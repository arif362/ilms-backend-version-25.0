# frozen_string_literal: true

module Lms
  module QueryParams
    module LibraryLocationParams
      extend ::Grape::API::Helpers
      params :library_location_create_params do
        requires :staff_id, type: Integer
        requires :code, type: String
        requires :location_type, type: String, values: LibraryLocation.location_types.keys
        optional :name, type: String
      end

      params :library_location_update_params do
        requires :staff_id, type: Integer
        requires :code, type: String
        requires :location_type, type: String, values: LibraryLocation.location_types.keys
        optional :name, type: String
      end

      params :library_location_delete_params do
        requires :staff_id, type: Integer
      end
    end
  end
end

# frozen_string_literal: true

module Lms
  module QueryParams
    module DamagedBiblioParams
      extend ::Grape::API::Helpers

      params :biblio_damaged_create_params do
        requires :staff_id, type: Integer, allow_blank: false
        requires :biblio_item_id, type: Integer, allow_blank: false
        requires :request_type, type: String, values: LostDamagedBiblio.request_types.keys, allow_blank: false
        requires :status, type: String, values: LostDamagedBiblio.statuses.keys, allow_blank: false
        optional :member_id, type: Integer, allow_blank: false
      end
    end
  end
end

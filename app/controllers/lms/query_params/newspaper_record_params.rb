# frozen_string_literal: true

module Lms
  module QueryParams
    module NewspaperRecordParams
      extend ::Grape::API::Helpers
      params :newspaper_record_create_params do
        requires :newspaper_id, type: Integer, allow_blank: false
        requires :language, type: String,allow_blank: false, values: %w[english bangla]
        requires :start_date, type: Date, allow_blank: false
        optional :end_date, type: Date, allow_blank: false
        optional :is_continue, type: Boolean, allow_blank: false, values: [true, false]
        requires :staff_id, type: Integer, allow_blank: false
        optional :is_binding, type: Boolean, allow_blank: false, values: [true, false]
      end

      params :newspaper_record_update_params do
        requires :end_date, type: Date, allow_blank: false
        requires :staff_id, type: Integer, allow_blank: false
      end
    end
  end
end

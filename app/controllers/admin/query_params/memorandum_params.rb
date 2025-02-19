# frozen_string_literal: true

module Admin
  module QueryParams
    module MemorandumParams
      extend ::Grape::API::Helpers

      params :memorandum_create_params do
        requires :memorandum_no, type: String
        requires :start_date, type: Date
        requires :end_date, type: Date
        requires :start_time, type: Time
        requires :end_time, type: Time
        requires :tender_session, type: String, regexp: /\A[1-9]\d{3}-[1-9]\d{3}\z/
        requires :last_submission_date, type: Date
        optional :description, type: String
        optional :memorandum_details, type: String
        optional :is_visible, type: Boolean
        optional :image_file, type: File
      end

      params :memorandum_update_params do
        requires :memorandum_no, type: String
        requires :start_date, type: Date
        requires :end_date, type: Date
        requires :start_time, type: Time
        requires :end_time, type: Time
        requires :tender_session, type: String, regexp: /\A[1-9]\d{3}-[1-9]\d{3}\z/
        requires :last_submission_date, type: Date
        optional :description, type: String
        optional :memorandum_details, type: String
        optional :is_visible, type: Boolean
        optional :image_file, type: File
      end

      params :memorandum_publisher_shortlist_params do
        requires :memorandum_publisher_ids, type: Array[Integer]
      end
    end
  end
end

# frozen_string_literal: true

module Lms
  module QueryParams
    module EventParams
      extend ::Grape::API::Helpers

      params :event_create_params do
        requires :staff_id, type: Integer
        requires :title, type: String
        requires :bn_title, type: String
        requires :details, type: String
        requires :bn_details, type: String
        requires :start_date, type: DateTime
        requires :end_date, type: DateTime
        requires :is_published, type: Boolean, default: false
        requires :is_registerable, type: Boolean
        requires :image_file, type: File
        requires :phone, type: String
        requires :email, type: String
        optional :registration_last_date, type: DateTime
        optional :registration_fields, type: Array
        requires :competition_info, type: Array do
          requires :competition_name, type: String
          requires :group_and_policies, type: Array do
            requires :group_name, type: String, values: EventRegistration.participate_groups.keys
            requires :group_policy, type: String
          end
        end
      end

      params :event_update_params do
        requires :staff_id, type: Integer
        requires :title, type: String
        requires :bn_title, type: String
        requires :details, type: String
        requires :bn_details, type: String
        requires :start_date, type: DateTime
        requires :end_date, type: DateTime
        requires :is_published, type: Boolean, default: false
        requires :is_registerable, type: Boolean
        requires :phone, type: String
        requires :email, type: String
        optional :registration_last_date, type: DateTime
        optional :registration_fields, type: Array
        optional :image_file, type: File
        requires :competition_info, type: Array do
          requires :competition_name, type: String
          requires :group_and_policies, type: Array do
            requires :group_name, type: String, values: EventRegistration.participate_groups.keys
            requires :group_policy, type: String
          end
        end
      end

      params :event_delete_params do
        requires :staff_id, type: Integer
      end
    end
  end
end

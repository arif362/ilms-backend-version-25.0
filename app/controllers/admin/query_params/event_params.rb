# frozen_string_literal: true

module Admin
  module QueryParams
    module EventParams
      extend ::Grape::API::Helpers

      params :event_create_params do
        requires :title, type: String
        requires :bn_title, type: String
        requires :details, type: String
        requires :bn_details, type: String
        requires :start_date, type: DateTime
        requires :end_date, type: DateTime
        requires :is_published, type: Boolean, default: false
        requires :phone, type: String
        requires :email, type: String
        optional :registration_last_date, type: DateTime
        optional :is_registerable, type: Boolean, default: false
        optional :registration_fields, type: Array
        requires :competition_info, type: Array do
          requires :competition_name, type: String
          requires :group_and_policies, type: Array do
            requires :group_name, type: String, values: EventRegistration.participate_groups.keys
            requires :group_policy, type: String
          end
        end
        requires :image_file, type: File
      end

      params :event_update_params do
        requires :title, type: String
        requires :bn_title, type: String
        requires :details, type: String
        requires :bn_details, type: String
        requires :start_date, type: DateTime
        requires :end_date, type: DateTime
        requires :is_published, type: Boolean
        requires :phone, type: String
        requires :email, type: String
        optional :registration_last_date, type: DateTime
        optional :is_registerable, type: Boolean
        optional :registration_fields, type: Array
        requires :competition_info, type: Array do
          requires :competition_name, type: String
          requires :group_and_policies, type: Array do
            requires :group_name, type: String, values: EventRegistration.participate_groups.keys
            requires :group_policy, type: String
          end
        end
        optional :image_file, type: File
      end
    end
  end
end

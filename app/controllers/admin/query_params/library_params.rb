# frozen_string_literal: true

module Admin
  module QueryParams
    module LibraryParams
      extend ::Grape::API::Helpers

      params :library_create_params do
        requires :name, type: String, allow_blank: false
        requires :bn_name, type: String, allow_blank: false
        optional :phone, type: String, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
        requires :description, type: String, allow_blank: false
        requires :bn_description, type: String, allow_blank: false
        requires :address, type: String
        requires :redx_area_id, type: Integer
        optional :email, type: String
        requires :bn_address, type: String
        requires :district_id, type: String, allow_blank: false
        requires :thana_id, type: Integer, allow_blank: false
        requires :ip_address, type: String, allow_blank: false
        requires :library_type, type: String, allow_blank: false, values: Library.library_types.keys
        requires :is_default_working_days, type: Boolean
        requires :password, type: String, allow_blank: false
        requires :password_confirmation, type: String, allow_blank: false, same_as: :password
        requires :username, type: String, allow_blank: false
        optional :library_working_days_attributes, type: Array do
          requires :week_days, type: String, values: LibraryWorkingDay.week_days.keys
          requires :is_holiday, type: Boolean
          optional :start_time, type: String, desc: 'Start time in 24-hour format (HH:mm)'
          optional :end_time, type: String, desc: 'End time in 24-hour format (HH:mm)'
        end
        optional :lat, type: String
        optional :long, type: String
        optional :is_active, type: Boolean, allow_blank: false
        optional :images_file, type: Array
        optional :hero_image_file, type: File
        optional :map_iframe, type: String
      end

      params :library_update_params do
        requires :name, type: String, allow_blank: false
        requires :bn_name, type: String, allow_blank: false
        optional :phone, type: String, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
        requires :description, type: String, allow_blank: false
        requires :bn_description, type: String, allow_blank: false
        requires :is_default_working_days, type: Boolean
        optional :email, type: String
        optional :library_working_days_attributes, type: Array do
          optional :id, type: Integer
          requires :week_days, type: String, values: LibraryWorkingDay.week_days.keys
          requires :is_holiday, type: Boolean
          optional :start_time, type: String, desc: 'Start time in 24-hour format (HH:mm)'
          optional :end_time, type: String, desc: 'End time in 24-hour format (HH:mm)'
        end
        optional :address, type: String
        optional :bn_address, type: String
        optional :lat, type: String
        optional :long, type: String
        optional :is_active, type: Boolean
        requires :district_id, type: String, allow_blank: false
        requires :thana_id, type: Integer, allow_blank: false
        requires :library_type, type: String, allow_blank: false, values: Library.library_types.keys
        optional :images_file, type: Array
        optional :hero_image_file, type: File
        optional :map_iframe, type: String
        requires :redx_area_id, type: Integer
      end

      params :library_remove_image_params do
        requires :image_id, type: Integer
      end

      params :library_password_change_params do
        requires :current_password, type: String, allow_blank: false
        requires :password, type: String, allow_blank: false
        requires :password_confirmation, type: String, allow_blank: false, same_as: :password
      end

      params :library_ip_change_params do
        requires :current_ip, type: String, allow_blank: false
        requires :ip_address, type: String, allow_blank: false
        requires :password, type: String, allow_blank: false, same_as: :password
      end
    end
  end
end

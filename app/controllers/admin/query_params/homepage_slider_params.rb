# frozen_string_literal: true

module Admin
  module QueryParams
    module HomepageSliderParams
      extend ::Grape::API::Helpers

      params :homepage_slider_create_params do
        requires :title, type: String
        requires :link, type: String
        requires :serial_no, type: Integer
        optional :is_visible, type: Boolean
        optional :image_file, type: File
      end

      params :homepage_slider_update_params do
        requires :title, type: String
        requires :link, type: String
        requires :serial_no, type: Integer
        optional :is_visible, type: Boolean
        optional :image_file, type: File
      end
    end
  end
end

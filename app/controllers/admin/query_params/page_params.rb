# frozen_string_literal: true

module Admin
  module QueryParams
    module PageParams
      extend ::Grape::API::Helpers
      params :page_create_params do
        requires :title, type: String, allow_blank: false
        requires :bn_title, type: String, allow_blank: false
        requires :description
        requires :bn_description, type: String, allow_blank: false
        optional :image_file, type: File
        optional :is_active, type: Boolean, values: [true, false]
      end

      params :page_update_params do
        requires :title, type: String, allow_blank: false
        requires :slug, type: String, allow_blank: false
        requires :bn_title, type: String, allow_blank: false
        requires :description, type: String, allow_blank: false
        requires :bn_description, type: String, allow_blank: false
        optional :image_file, type: File
        optional :is_active, type: Boolean, values: [true, false]
      end
    end
  end
end

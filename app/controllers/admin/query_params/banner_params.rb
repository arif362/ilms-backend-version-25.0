# frozen_string_literal: true

module Admin
  module QueryParams
    module BannerParams
      extend ::Grape::API::Helpers

      params :banner_create_params do
        requires :title, type: String
        requires :bn_title, type: String
        requires :position, type: Integer
        requires :page_type_id, type: Integer
        requires :image_file, type: File
        optional :is_visible, type: Boolean
      end

      params :banner_update_params do
        requires :title, type: String
        requires :bn_title, type: String
        requires :slug, type: String
        requires :position, type: Integer
        requires :page_type_id, type: Integer
        optional :is_visible, type: Boolean
        optional :image_file, type: File
      end
    end
  end
end

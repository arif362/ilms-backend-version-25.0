# frozen_string_literal: true

module Admin
  module QueryParams
    module KeyPersonParams
      extend ::Grape::API::Helpers

      params :key_person_create_params do
        requires :name, type: String
        requires :bn_name, type: String
        requires :designation, type: String
        requires :bn_designation, type: String
        requires :description, type: String
        requires :bn_description, type: String
        requires :position, type: Integer
        requires :image_file, type: File
        optional :is_active, type: Boolean
      end

      params :key_person_update_params do
        requires :name, type: String
        requires :bn_name, type: String
        requires :slug, type: String
        requires :designation, type: String
        requires :bn_designation, type: String
        requires :description, type: String
        requires :bn_description, type: String
        requires :position, type: Integer
        optional :is_active, type: Boolean
        optional :image_file, type: File
      end
    end
  end
end

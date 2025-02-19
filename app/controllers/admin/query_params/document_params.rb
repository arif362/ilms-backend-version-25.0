# frozen_string_literal: true

module Admin
  module QueryParams
    module DocumentParams
      extend ::Grape::API::Helpers

      params :document_create_params do
        requires :name, allow_blank: false, type: String
        requires :bn_name, allow_blank: false, type: String
        optional :description, allow_blank: false, type: String
        optional :bn_description, allow_blank: false, type: String
        requires :document_category_id, allow_blank: false, type: Integer
        requires :document_file, allow_blank: false, type: File
      end

      params :document_update_params do
        requires :name, allow_blank: false, type: String
        requires :bn_name, allow_blank: false, type: String
        optional :description, allow_blank: false, type: String
        optional :bn_description, allow_blank: false, type: String
        requires :document_category_id, allow_blank: false, type: Integer
        optional :document_file, allow_blank: false, type: File
      end
    end
  end
end

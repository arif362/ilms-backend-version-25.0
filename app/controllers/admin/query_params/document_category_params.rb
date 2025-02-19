# frozen_string_literal: true

module Admin
  module QueryParams
    module DocumentCategoryParams
      extend ::Grape::API::Helpers

      params :document_category_create_params do
        requires :name, allow_blank: false, type: String
      end

      params :document_category_update_params do
        requires :name, allow_blank: false, type: String
      end
    end
  end
end

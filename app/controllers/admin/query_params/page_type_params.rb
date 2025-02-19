# frozen_string_literal: true

module Admin
  module QueryParams
    module PageTypeParams
      extend ::Grape::API::Helpers

      params :page_type_create_params do
        requires :title, type: String
      end

      params :page_type_update_params do
        requires :title, type: String
      end
    end
  end
end

# frozen_string_literal: true

module Admin
  module QueryParams
    module FaqCategoryParams
      extend ::Grape::API::Helpers

      params :faq_category_create_params do
        requires :title, type: String
        requires :bn_title, type: String
      end

      params :faq_category_update_params do
        requires :title, type: String
        requires :bn_title, type: String
      end
    end
  end
end

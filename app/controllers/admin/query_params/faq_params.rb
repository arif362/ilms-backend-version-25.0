# frozen_string_literal: true

module Admin
  module QueryParams
    module FaqParams
      extend ::Grape::API::Helpers

      params :faq_create_params do
        requires :question, type: String
        requires :bn_question, type: String
        requires :answer, type: String
        requires :bn_answer, type: String
        requires :position, type: Integer
        requires :faq_category_id, type: Integer
        optional :is_published, type: Boolean, default: false
      end

      params :faq_update_params do
        requires :question, type: String
        requires :bn_question, type: String
        requires :answer, type: String
        requires :bn_answer, type: String
        requires :position, type: Integer
        requires :faq_category_id, type: Integer
        optional :is_published, type: Boolean
      end
    end
  end
end

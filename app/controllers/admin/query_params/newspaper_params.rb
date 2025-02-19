# frozen_string_literal: true

module Admin
  module QueryParams
    module NewspaperParams
      extend ::Grape::API::Helpers

      params :newspaper_create_params do
        requires :name, type: String, allow_blank: false
        requires :bn_name, type: String, allow_blank: false
        requires :is_published, type: Boolean, allow_blank: false, values: [true, false]
        requires :category, type: String, allow_blank: false, values: Newspaper.categories.keys
        requires :language, type: String, allow_blank: false, values: Newspaper.languages.keys
      end

      params :newspaper_update_params do
        requires :name, type: String, allow_blank: false
        requires :bn_name, type: String, allow_blank: false
        requires :is_published, type: Boolean, allow_blank: false, values: [true, false]
        requires :category, type: String, allow_blank: false, values: Newspaper.categories.keys
        requires :language, type: String, allow_blank: false, values: Newspaper.languages.keys
      end
    end
  end
end

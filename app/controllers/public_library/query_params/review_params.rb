# frozen_string_literal: true

module PublicLibrary
  module QueryParams
    module ReviewParams
      extend ::Grape::API::Helpers
      params :review_create_params do
        requires :text, type: String, allow_blank: false
        requires :rating, type: Integer, allow_blank: false, values: [1, 2, 3, 4, 5]
      end
    end
  end
end

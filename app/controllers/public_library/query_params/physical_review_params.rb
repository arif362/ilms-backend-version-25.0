# frozen_string_literal: true

module PublicLibrary
  module QueryParams
    module PhysicalReviewParams
      extend ::Grape::API::Helpers

      params :physical_reviews_create_params do
        requires :barcode, allow_blank: false
        requires :review_body, allow_blank: false, type: String
        optional :book_image_file, type: File
      end
    end
  end
end

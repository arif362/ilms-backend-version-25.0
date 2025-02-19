# frozen_string_literal: true

module PublicLibrary
  module QueryParams
    module ComplainParams
      extend ::Grape::API::Helpers
      params :complain_create_params do
        requires :complain_type, type: String, values: %w[book_issue payment_issue library_issue delivery_issue others]
        requires :description, type: String
        optional :library_id, type: Integer
        optional :images_file, type: Array
        requires :phone, type: String
        optional :email, type: String
        requires :subject, type: String
      end

      # params :complain_update_params do
      #   requires :complain_type, type: String, values: %w[book_issue payment_issue library_issue delivery_issue others]
      #   requires :description, type: String
      #   optional :library_id, type: Integer
      #   optional :images_file, type: Array
      #   requires :phone, type: String
      #   optional :email, type: String
      #   requires :subject, type: String
      # end
    end
  end
end

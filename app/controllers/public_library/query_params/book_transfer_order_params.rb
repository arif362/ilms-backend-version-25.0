# frozen_string_literal: true

module PublicLibrary
  module QueryParams
    module BookTransferOrderParams
      extend ::Grape::API::Helpers
      params :book_transfer_order_create_params do
        requires :biblio_id, type: String
        requires :library_id, type: Integer
      end
    end
  end
end

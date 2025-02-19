# frozen_string_literal: true

module PublicLibrary
  module QueryParams
    module ExtendRequestParams
      extend ::Grape::API::Helpers

      params :extend_request_create_params do
        requires :circulation_ids, type: Array[Integer]
      end
    end
  end
end

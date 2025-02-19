# frozen_string_literal: true

module PublicLibrary
  module QueryParams
    module PublisherParams
      extend ::Grape::API::Helpers

      params :publisher_create_params do
        requires :publication_name, allow_blank: false, type: String
        requires :address, allow_blank: false, type: String
        optional :name, type: String, allow_blank: false
        optional :author_name, type: String, allow_blank: false
        optional :organization_phone, type: String, allow_blank: false, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
        optional :organization_email, type: String, allow_blank: false, regexp: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
      end
      params :publisher_update_params do
        requires :publication_name, type: String, allow_blank: false
        requires :address, type: String, allow_blank: false
        optional :name, type: String, allow_blank: false
        optional :author_name, type: String, allow_blank: false
        optional :organization_phone, type: String, allow_blank: false, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
        optional :organization_email, type: String, allow_blank: false, regexp: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
      end

    end
  end
end

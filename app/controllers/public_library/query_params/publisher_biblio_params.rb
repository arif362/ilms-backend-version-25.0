# frozen_string_literal: true

module PublicLibrary
  module QueryParams
    module PublisherBiblioParams
      extend ::Grape::API::Helpers
      params :publisher_biblio_create_params do
        requires :memorandum_id, type: Integer
        requires :author_name, type: String
        requires :title, type: String
        requires :publication_date, type: Date
        requires :edition, type: String
        requires :print, type: String
        requires :total_page, type: Integer
        requires :subject, type: String
        requires :price, type: Float
        requires :isbn, type: String
        requires :paper_type, type: String, values: PublisherBiblio.paper_types.keys
        requires :binding_type, type: String, values: PublisherBiblio.binding_types.keys
        requires :is_foreign, type: Boolean
        optional :publisher_name, type: String
        optional :publisher_phone, type: String, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
        optional :publisher_address, type: String
        optional :publisher_website, type: String
        optional :comment, type: String
      end

      params :publisher_biblio_update_params do
        requires :author_name, type: String
        requires :title, type: String
        requires :publication_date, type: Date
        requires :edition, type: String
        requires :print, type: String
        requires :total_page, type: Integer
        requires :subject, type: String
        requires :price, type: Float
        requires :isbn, type: String
        requires :paper_type, type: String, values: PublisherBiblio.paper_types.keys
        requires :binding_type, type: String, values: PublisherBiblio.binding_types.keys
        requires :is_foreign, type: Boolean
        optional :publisher_name, type: String
        optional :publisher_phone, type: String, regexp: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/
        optional :publisher_address, type: String
        optional :publisher_website, type: String
        optional :comment, type: String
      end
    end
  end
end

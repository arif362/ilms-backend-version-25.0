# frozen_string_literal: true

module Lms
  module QueryParams
    module BiblioItemParams
      extend ::Grape::API::Helpers

      params :multiple_biblio_item_create_params do
        requires :staff_id, type: Integer
        requires :biblio_item_type, type: String, values: BiblioItem.biblio_item_types.keys
        requires :permanent_library_location_id, type: Integer
        optional :current_library_location_id, type: Integer
        optional :shelving_library_location_id, type: Integer
        optional :price, type: Numeric
        optional :full_call_number, type: String
        optional :note, type: String
        requires :not_for_loan, type: Boolean, values: [true, false]
        optional :date_accessioned, type: DateTime
        optional :preview_file, type: File
        optional :full_ebook_file, type: File
        optional :item_collection_type, type: String, values: %w[department library existing]
        requires :biblio_item_create_params, type: Array do
          requires :barcode, type: String, allow_blank: false
          requires :accession_no, type: String, allow_blank: false
          optional :central_accession_no, type: Integer
          requires :item_collection_type, type: String, values: %w[department library existing]
          optional :copy_number, type: String
        end
      end

      params :biblio_item_create_params do
        requires :staff_id, type: Integer
        requires :barcode, type: String, allow_blank: false
        requires :accession_no, type: String, allow_blank: false
        optional :central_accession_no, type: Integer
        requires :biblio_item_type, type: String, values: BiblioItem.biblio_item_types.keys
        requires :permanent_library_location_id, type: Integer
        optional :current_library_location_id, type: Integer
        optional :shelving_library_location_id, type: Integer
        optional :price, type: Numeric
        optional :full_call_number, type: String
        optional :note, type: String
        optional :copy_number, type: String
        requires :not_for_loan, type: Boolean, values: [true, false]
        optional :date_accessioned, type: DateTime
        requires :item_collection_type, type: String, values: %w[department library existing]
        optional :preview_file, type: File
        optional :full_ebook_file, type: File
      end

      params :biblio_item_update_params do
        requires :staff_id, type: Integer
        requires :barcode, type: String, allow_blank: false
        requires :accession_no, type: String, allow_blank: false
        optional :central_accession_no, type: Integer
        requires :biblio_item_type, type: String, values: BiblioItem.biblio_item_types.keys
        optional :permanent_library_location_id, type: Integer
        optional :current_library_location_id, type: Integer
        optional :shelving_library_location_id, type: Integer
        optional :price, type: Numeric
        optional :full_call_number, type: String
        optional :note, type: String
        optional :copy_number, type: String
        requires :not_for_loan, type: Boolean, values: [true, false]
        optional :date_accessioned, type: DateTime
        optional :preview_file, type: File
        optional :full_ebook_file, type: File
      end

      params :multiple_biblio_item_update_params do
        requires :biblio_item_ids, type: Array
        requires :staff_id, type: Integer
        requires :biblio_item_type, type: String, values: BiblioItem.biblio_item_types.keys
        optional :permanent_library_location_id, type: Integer
        optional :current_library_location_id, type: Integer
        optional :shelving_library_location_id, type: Integer
        optional :price, type: Numeric
        optional :full_call_number, type: String
        optional :note, type: String
        requires :not_for_loan, type: Boolean, values: [true, false]
        optional :date_accessioned, type: DateTime
        optional :preview_file, type: File
        optional :full_ebook_file, type: File
      end
    end
  end
end

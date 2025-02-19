# frozen_string_literal: true

module Lms
  module QueryParams
    module BiblioParams
      extend ::Grape::API::Helpers
      params :biblio_create_params do
        requires :staff_id, type: Integer
        requires :title, type: String, allow_blank: false
        requires :item_type_id, type: Integer
        optional :biblio_classification_source_id, type: Integer
        optional :author_ids, type: Array
        optional :editor_ids, type: Array
        optional :translator_ids, type: Array
        optional :contributor_ids, type: Array
        optional :biblio_subject_biblios_attributes, type: Array do
          requires :biblio_subject_id, type: Integer
        end
        optional :remainder_of_title, type: String
        optional :copyright_date, type: Date
        optional :isbn, type: Integer, allow_blank: false
        optional :original_cataloging_agency, type: String
        optional :calaloging_language, type: String
        optional :ddc_edition_number, type: String
        optional :ddc_classification_number, type: String
        optional :ddc_item_number, type: String
        optional :biblio_edition_id, type: Integer
        optional :biblio_publication_id, type: Integer
        optional :physical_details, type: String
        optional :other_physical_details, type: String
        optional :dimentions, type: String
        optional :series_statement_title, type: String
        optional :series_statement_volume, type: String
        optional :issn, type: String
        optional :series_statement, type: String
        optional :general_note, type: String
        optional :bibliography_note, type: String
        optional :contents_note, type: String
        optional :topical_term, type: String
        requires :full_call_number, type: String
        optional :pages, type: Integer
        optional :age_restriction, type: String
        optional :corporate_name, type: String
        optional :statement_of_responsibility, type: String
        optional :edition_statement, type: String
        optional :place_of_publication, type: String
        optional :date_of_publication, type: Integer, values: 1000..9999
        optional :extent, type: String
        optional :image_file, type: File
        optional :preview_ebook_file_url, type: String, regexp: URI::DEFAULT_PARSER.make_regexp
        optional :full_ebook_file_url, type: String, regexp: URI::DEFAULT_PARSER.make_regexp
        optional :full_pdf_file_url, type: String, regexp: URI::DEFAULT_PARSER.make_regexp
        optional :table_of_content_file, type: File
        optional :table_of_context, type: String
        optional :is_published, type: Boolean
      end



      params :biblio_update_params do
        requires :staff_id, type: Integer
        requires :title, type: String, allow_blank: false
        requires :item_type_id, type: Integer
        optional :biblio_classification_source_id, type: Integer
        optional :author_ids, type: Array[Integer], allow_blank: false
        optional :editor_ids, type: Array[Integer], allow_blank: false
        optional :translator_ids, type: Array[Integer], allow_blank: false
        optional :contributor_ids, type: Array, allow_blank: false
        optional :biblio_subject_biblios_attributes, type: Array do
          requires :biblio_subject_id, type: Integer
        end
        optional :remainder_of_title, type: String, allow_blank: false
        optional :copyright_date, type: Date, allow_blank: false
        optional :isbn, type: Integer, allow_blank: false
        optional :original_cataloging_agency, type: String, allow_blank: false
        optional :calaloging_language, type: String, allow_blank: false
        optional :ddc_edition_number, type: String, allow_blank: false
        optional :ddc_classification_number, type: String, allow_blank: false
        optional :ddc_item_number, type: String, allow_blank: false
        optional :biblio_edition_id, type: Integer
        optional :biblio_publication_id, type: Integer
        optional :physical_details, type: String, allow_blank: false
        optional :other_physical_details, type: String, allow_blank: false
        optional :dimentions, type: String, allow_blank: false
        optional :series_statement_title, type: String, allow_blank: false
        optional :series_statement_volume, type: String, allow_blank: false
        optional :issn, type: String, allow_blank: false
        optional :series_statement, type: String, allow_blank: false
        optional :general_note, type: String, allow_blank: false
        optional :bibliography_note, type: String, allow_blank: false
        optional :contents_note, type: String, allow_blank: false
        optional :topical_term, type: String, allow_blank: false
        requires :full_call_number, type: String, allow_blank: false
        optional :pages, type: Integer
        optional :age_restriction, type: String, allow_blank: false
        optional :corporate_name, type: String, allow_blank: false
        optional :statement_of_responsibility, type: String, allow_blank: false
        optional :edition_statement, type: String, allow_blank: false
        optional :place_of_publication, type: String, allow_blank: false
        optional :date_of_publication, type: Integer, values: 1000..9999
        optional :extent, type: String, allow_blank: false
        optional :image_file, type: File
        optional :preview_ebook_file_url, type: String, allow_blank: false, regexp: URI::DEFAULT_PARSER.make_regexp
        optional :full_ebook_file_url, type: String, allow_blank: false, regexp: URI::DEFAULT_PARSER.make_regexp
        optional :full_pdf_file_url, type: String, allow_blank: false, regexp: URI::DEFAULT_PARSER.make_regexp
        optional :table_of_content, type: File
        optional :table_of_context, type: String, allow_blank: false
        optional :is_published, type: Boolean

      end
    end
  end
end

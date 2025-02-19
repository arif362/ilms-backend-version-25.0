# frozen_string_literal: true

module Lms
  module QueryParams
    module RequestBiblioParams
      extend ::Grape::API::Helpers
      params :create_params do
        requires :staff_id, type: Integer, allow_blank: false
        requires :biblio_title, type: String
        optional :author_requested_biblios_attributes, type: Array do
          requires :author_id, type: Integer
        end
        optional :authors_name, type: Array
        optional :biblio_subject_requested_biblios_attributes, type: Array do
          requires :biblio_subject_id, type: Integer
        end
        optional :biblio_subjects_name, type: Array
        optional :isbn, type: String
        optional :publication, type: String
        optional :edition, type: String
        optional :volume, type: String
        optional :image_file, type: File
      end

      params :multiple_create_params do
        requires :biblios, type: Array do
          requires :staff_id, type: Integer, allow_blank: false
          requires :biblio_title, type: String
          optional :author_requested_biblios_attributes, type: Array do
            requires :author_id, type: Integer
          end
          optional :authors_name, type: Array
          optional :biblio_subject_requested_biblios_attributes, type: Array do
            requires :biblio_subject_id, type: Integer
          end
          optional :biblio_subjects_name, type: Array
          optional :isbn, type: String
          optional :publication, type: String
          optional :edition, type: String
          optional :volume, type: String
          optional :image_file, type: File
        end
      end
    end
  end
end

# frozen_string_literal: true

module PublicLibrary
  module QueryParams
    module RequestedBibliosParams
      extend ::Grape::API::Helpers
      params :requested_biblios_create_params do
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

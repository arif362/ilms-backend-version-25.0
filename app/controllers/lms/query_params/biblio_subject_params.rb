# frozen_string_literal: true

module Lms
  module QueryParams
    module BiblioSubjectParams
      extend ::Grape::API::Helpers

      params :biblio_subject_create_params do
        requires :staff_id, type: Integer
        requires :personal_name, type: String
        requires :bn_personal_name, type: String
        optional :corporate_name, type: String
        optional :topical_name, type: String
        optional :geographic_name, type: String
      end

      params :biblio_subject_update_params do
        requires :staff_id, type: Integer
        requires :personal_name, type: String
        requires :bn_personal_name, type: String
        optional :slug, type: String
        optional :corporate_name, type: String
        optional :topical_name, type: String
        optional :geographic_name, type: String
      end

      params :biblio_subject_delete_params do
        requires :staff_id, type: Integer
      end
    end
  end
end

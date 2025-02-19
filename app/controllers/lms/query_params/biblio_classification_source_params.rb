# frozen_string_literal: true

module Lms
  module QueryParams
    module BiblioClassificationSourceParams
      extend ::Grape::API::Helpers
      params :biblio_classification_source_create_params do
        requires :staff_id, type: Integer
        requires :title, type: String, allow_blank: false
      end

      params :biblio_classification_source_update_params do
        requires :staff_id, type: Integer
        requires :title, type: String, allow_blank: false
      end

      params :biblio_classification_source_delete_params do
        requires :staff_id, type: Integer
      end
    end
  end
end

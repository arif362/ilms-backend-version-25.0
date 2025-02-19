# frozen_string_literal: true

module Lms
  module QueryParams
    module BiblioPublicationParams
      extend ::Grape::API::Helpers
      params :biblio_publication_create_params do
        requires :staff_id, type: Integer
        requires :title, type: String, allow_blank: false
        requires :bn_title, type: String, allow_blank: false
      end

      params :biblio_publication_update_params do
        requires :staff_id, type: Integer
        requires :title, type: String, allow_blank: false
        requires :bn_title, type: String, allow_blank: false
      end

      params :biblio_publication_delete_params do
        requires :staff_id, type: Integer
      end
    end
  end
end

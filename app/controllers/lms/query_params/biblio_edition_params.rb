# frozen_string_literal: true

module Lms
  module QueryParams
    module BiblioEditionParams
      extend ::Grape::API::Helpers
      params :biblio_edition_create_params do
        requires :staff_id, type: Integer
        requires :title, type: String
        optional :description, type: String
      end

      params :biblio_edition_update_params do
        requires :staff_id, type: Integer
        requires :title, type: String
        optional :description, type: String
      end

      params :biblio_edition_delete_params do
        requires :staff_id, type: Integer
      end
    end
  end
end

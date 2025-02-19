# frozen_string_literal: true

module Lms
  module QueryParams
    module RebindBiblioParams
      extend ::Grape::API::Helpers

      params :rebind_biblio_create_params do
        requires :staff_id, type: Integer
        requires :biblio_item_id, type: Integer
      end

      params :rebind_biblio_update_params do
        requires :staff_id, type: Integer
        requires :accession_numbers, type: Array[String], allow_blank: false
      end
    end
  end
end

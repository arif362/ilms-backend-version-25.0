# frozen_string_literal: true

module Lms
  module QueryParams
    module AuthorParams
      extend ::Grape::API::Helpers

      params :author_create_params do
        requires :staff_id, type: Integer
        requires :first_name, type: String
        requires :bn_first_name, type: String
        optional :dob, type: Integer, values: 1000..9999
        optional :dod, type: Integer, values: 1000..9999
        optional :pob, type: String
        optional :middle_name, type: String
        optional :bn_middle_name, type: String
        optional :last_name, type: String
        optional :bn_last_name, type: String
        optional :title, type: String
        optional :bn_title, type: String
      end

      params :author_update_params do
        requires :staff_id, type: Integer
        requires :first_name, type: String
        requires :bn_first_name, type: String
        optional :dob, type: Integer, values: 1000..9999
        optional :dod, type: Integer, values: 1000..9999
        optional :pob, type: String
        optional :middle_name, type: String
        optional :bn_middle_name, type: String
        optional :last_name, type: String
        optional :bn_last_name, type: String
        optional :title, type: String
        optional :bn_title, type: String
      end

      params :author_delete_params do
        requires :staff_id, type: Integer
      end
    end
  end
end

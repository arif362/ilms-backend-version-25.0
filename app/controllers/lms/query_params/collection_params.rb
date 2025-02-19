# collectionparams.rb

module Lms
  module QueryParams
    module CollectionParams
      extend Grape::API::Helpers

      params :collection_create_params do
        requires :title, type: String
        requires :staff_id, type: Integer
      end

      params :collection_update_params do
        optional :title, type: String
        requires :staff_id, type: Integer
      end

      params :collection_title_search_params do
        optional :title, type: String
      end
      params :collection_delete_params do
        requires :staff_id, type: Integer
      end
    end
  end
end

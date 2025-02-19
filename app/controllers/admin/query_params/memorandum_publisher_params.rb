# frozen_string_literal: true

module Admin
  module QueryParams
    module MemorandumPublisherParams
      extend ::Grape::API::Helpers

      params :publisher_biblio_shortlist_params do
        requires :publisher_biblio_ids, type: Array[Integer]
      end
    end
  end
end

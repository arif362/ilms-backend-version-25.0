# frozen_string_literal: true

module PublicLibrary
  module Helpers
    module FailedSearchHelper
      extend Grape::API::Helpers
      def add_failed_search(keyword)
        failed_search = FailedSearch.find_by('lower(keyword) = ?', keyword.downcase)
        if failed_search.present?
          failed_search.update!(search_count: failed_search.search_count + 1)
        else
          FailedSearch.create!(keyword:)
        end
      end
    end
  end
end

# frozen_string_literal: true

module Admin
  module Entities
    class FailedSearches < Grape::Entity
      format_with(:iso_date, &:to_date)

      expose :id
      expose :keyword
      expose :search_count
      expose :created_at, as: :first_search, format_with: :iso_date
      expose :updated_at, as: :last_search, format_with: :iso_date
    end
  end
end

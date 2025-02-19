# frozen_string_literal: true

module NewspaperSearchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    mapping do
      indexes :name, type: :text
    end

    def self.search(query)
      params = {
        query: {
          multi_match: {
            query:,
            fields: %i[name]
          }
        }
      }
      __elasticsearch__.search(params)
    end
  end
end
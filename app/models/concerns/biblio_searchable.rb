# frozen_string_literal: true

module BiblioSearchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    mapping do
      indexes :title, type: :text
    end

    def self.search(query)
      params = {
        query: {
          multi_match: {
            query:,
            fields: %i[title]
          }
        }
      }
      __elasticsearch__.search(params)
    end
  end
end

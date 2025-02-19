# frozen_string_literal: true

module Lms
  module Entities
    class BiblioClassificationSources < Grape::Entity
      expose :id
      expose :title
      expose :created_by_id
      expose :updated_by_id
      expose :deleted_at
      expose :created_at
      expose :updated_at
    end
  end
end

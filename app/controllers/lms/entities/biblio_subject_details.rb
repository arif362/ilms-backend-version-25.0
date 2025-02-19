# frozen_string_literal: true

module Lms
  module Entities
    class BiblioSubjectDetails < Grape::Entity
      expose :id
      expose :personal_name
      expose :bn_personal_name
      expose :slug
      expose :corporate_name
      expose :topical_name
      expose :geographic_name
      expose :is_deleted
      expose :created_by_id
      expose :updated_by_id
      expose :deleted_at
      expose :created_at
      expose :updated_at
    end
  end
end

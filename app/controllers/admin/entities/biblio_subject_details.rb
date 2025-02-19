# frozen_string_literal: true

module Admin
  module Entities
    class BiblioSubjectDetails < Grape::Entity
      expose :id
      expose :personal_name
      expose :bn_personal_name
      expose :slug
      expose :corporate_name
      expose :topical_name
      expose :geographic_name
    end
  end
end

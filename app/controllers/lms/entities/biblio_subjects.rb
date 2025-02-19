# frozen_string_literal: true

module Lms
  module Entities
    class BiblioSubjects < Grape::Entity
      expose :id
      expose :personal_name
      expose :bn_personal_name
      expose :corporate_name
      expose :topical_name
      expose :geographic_name
    end
  end
end

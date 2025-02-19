# frozen_string_literal: true

module Lms
  module Entities
    class BiblioSubjectSearch < Grape::Entity
      expose :id
      expose :personal_name
      expose :bn_personal_name
    end
  end
end

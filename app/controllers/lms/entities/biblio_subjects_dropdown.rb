# frozen_string_literal: true

module Lms
  module Entities
    class BiblioSubjectsDropdown < Grape::Entity
      expose :id
      expose :personal_name
    end
  end
end

# frozen_string_literal: true

module Lms
  module Entities
    class AuthorSearch < Grape::Entity
      expose :id
      expose :name_dob

      def name_dob
        "#{object.full_name} - #{object.dob}"
      end
    end
  end
end

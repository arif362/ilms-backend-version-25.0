# frozen_string_literal: true

module Lms
  module Entities
    class Thanas < Grape::Entity
      expose :id
      expose :name
      expose :bn_name
      expose :district

      def district
        district = object&.district
        {
          id: district&.id,
          name: district&.name,
          bn_name: district&.bn_name
        }
      end
    end
  end
end

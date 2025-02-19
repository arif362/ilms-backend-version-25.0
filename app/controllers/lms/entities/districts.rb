# frozen_string_literal: true

module Lms
  module Entities
    class Districts < Grape::Entity
      expose :id
      expose :name
      expose :bn_name
      expose :division

      def division
        division = object&.division
        {
          id: division&.id,
          name: division&.name,
          bn_name: division&.bn_name
        }
      end
    end
  end
end

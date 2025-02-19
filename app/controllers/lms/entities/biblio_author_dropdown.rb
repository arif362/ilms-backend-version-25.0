module Lms
  module Entities
    class BiblioAuthorDropdown < Grape::Entity
      expose :id
      expose :full_name

      def full_name
        object&.full_name
      end
    end
  end
end

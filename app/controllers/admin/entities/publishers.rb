module Admin
  module Entities
    class Publishers < Grape::Entity
      expose :id
      expose :track_no
      expose :name
      expose :publication_name
      expose :author_name
      expose :address
      expose :phone

      def phone
        object&.user&.phone
      end
    end
  end
end

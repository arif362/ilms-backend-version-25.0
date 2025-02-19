module PublicLibrary
  module Entities
    class Complains < Grape::Entity
      expose :id
      expose :complain_type
      expose :created_at
      expose :subject

      def created_at
        object.created_at.to_date
      end
    end
  end
end

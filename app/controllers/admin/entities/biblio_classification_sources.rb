module Admin
  module Entities
    class BiblioClassificationSources < Grape::Entity
      expose :id
      expose :title
      expose :created_at
      expose :creator_stuff

      def creator_stuff
        AdminStaffLibrary.creator_stuff(object.created_by_id)
      end
    end
  end
end
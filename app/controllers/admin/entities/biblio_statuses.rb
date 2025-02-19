module Admin
  module Entities
    class BiblioStatuses < Grape::Entity
      expose :id
      expose :title
      expose :status_type
      expose :creator_stuff

      def creator_stuff
        AdminStaffLibrary.creator_stuff(object.created_by_id)
      end
    end
  end
end


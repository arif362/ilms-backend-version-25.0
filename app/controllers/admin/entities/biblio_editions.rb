module Admin
  module Entities
    class BiblioEditions < Grape::Entity
      expose :id
      expose :title
      expose :description
      expose :creator_stuff
      def creator_stuff
        AdminStaffLibrary.creator_stuff(object.created_by_id)
      end
    end
  end
end
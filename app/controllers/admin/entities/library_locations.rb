module Admin
  module Entities
    class LibraryLocations < Grape::Entity
      expose :id
      expose :library_id
      expose :name
      expose :code
      expose :location_type
      expose :creator_stuff

      def creator_stuff
        AdminStaffLibrary.creator_stuff(object.created_by_id)
      end
    end
  end
end
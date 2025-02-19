module Admin
  module Entities
    class AdminStaffLibrary < Grape::Entity
      def self.creator_stuff(created_by_id)
        staff = Staff.find_by(id: created_by_id)
        return if staff.nil?

        {
          id: staff.id,
          staff_name: staff.name,
          staff_email: staff.email,
          staff_phone: staff.phone,
          library: {
            id: staff.library&.id,
            library_code: staff.library&.code
          }
        }
      end
    end
  end
end
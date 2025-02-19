# frozen_string_literal: true

module Admin
  module Entities
    class Libraries < Grape::Entity
      expose :id
      expose :code
      expose :name
      expose :librarian_name
      expose :email
      expose :phone
      expose :district
      expose :thana



      def librarian_name
        library_head = object&.staffs&.find_by(is_library_head: true)
        {
          id: library_head&.id,
          name: library_head&.name
        }
      end

      def district
        district = object.thana&.district
        {
          id: district&.id,
          name: district&.name
        }
      end

      def thana
        {
          id: object&.thana&.id,
          name: object&.thana&.name
        }
      end
    end
  end
end

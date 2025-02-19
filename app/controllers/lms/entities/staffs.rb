# frozen_string_literal: true

module Lms
  module Entities
    class Staffs < Grape::Entity
      include Lms::Helpers::ImageHelpers

      expose :id, as: :ref_id
      expose :id, as: :staff_id
      expose :unique_id
      expose :name
      expose :email
      expose :email, as: :user_name
      expose :phone
      expose :gender
      expose :role
      expose :library
      expose :designation
      expose :is_active
      expose :staff_type
      expose :is_library_head
      expose :avatar_url
      expose :category
      expose :dob
      expose :joining_date
      expose :joining_library_id
      expose :sanctioned_post
      expose :staff_class
      expose :staff_grade

      def category
        0
      end

      def unique_id
        object&.unique_id
      end

      def role
        role = Role.find_by(id: object&.role_id)
        {
          id: role&.id || nil,
          title: role&.title || ''
        }
      end

      def library
        library = Library.find_by(id: object&.library_id)
        {
          id: library&.id || nil,
          title: library&.name || ''
        }
      end

      def designation
        designation = Designation.find_by(id: object&.designation_id)
        {
          id: designation&.id || nil,
          title: designation&.title || ''
        }
      end

      def avatar_url
        image_path(object.avatar)
      end
    end
  end
end

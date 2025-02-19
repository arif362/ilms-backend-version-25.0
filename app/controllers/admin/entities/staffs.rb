module Admin
  module Entities
    class Staffs < Grape::Entity
      include Admin::Helpers::ImageHelpers

      expose :id
      expose :unique_id
      expose :name
      expose :email
      expose :phone
      expose :gender
      expose :role
      expose :library
      expose :location
      expose :designation
      expose :is_active
      expose :staff_type
      expose :is_library_head
      expose :creation_date
      expose :dob
      expose :joining_date
      expose :joining_library_id
      expose :sanctioned_post
      expose :staff_class
      expose :staff_grade
      expose :avatar_url
      expose :authorized_signature_url
      expose :retired_date

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

      def location
        Library.find_by(id: object&.library_id)&.thana&.district&.name
      end

      def designation
        designation = Designation.find_by(id: object&.designation_id)
        {
          id: designation&.id || nil,
          title: designation&.title || ''
        }
      end

      def creation_date
        object&.created_at&.to_date
      end

      def avatar_url
        image_path(object.avatar)
      end

      def authorized_signature_url
        image_path(object.authorized_signature)
      end
    end
  end
end

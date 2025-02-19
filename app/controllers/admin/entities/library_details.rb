module Admin
  module Entities
    class LibraryDetails < Grape::Entity
      include Admin::Helpers::ImageHelpers

      expose :id
      expose :name
      expose :bn_name
      expose :description
      expose :bn_description
      expose :librarian, using: Admin::Entities::Staffs
      expose :phone
      expose :email
      expose :created_at
      expose :catalog
      expose :district
      expose :thana
      expose :lat
      expose :long
      expose :is_active
      expose :address
      expose :bn_address
      expose :ip_address
      expose :is_default_working_days
      expose :working_days
      expose :library_images
      expose :hero_image_url
      expose :username
      expose :division
      expose :library_type
      expose :staff_list, using: Admin::Entities::Staffs
      expose :map_iframe
      expose :redx_area_id

      def librarian
        object&.staffs&.find_by(is_library_head: true)
      end

      def staff_list
        object&.staffs
      end

      def catalog
        object&.biblio_libraries&.size # it will be fetch from catalog after implementing the books/catalog
      end

      def district
        object.thana.district.as_json(only: [:id, :name])
      end

      def thana
        object.thana.as_json(only: [:id, :name])
      end

      def library_images
        library_images = library_admin_images(object.images)
        library_images.nil? ? [] : library_images
      end

      def hero_image_url
        thumb_image(object.hero_image)
      end

      def working_days
        working_days = if object.is_default_working_days
                         LibraryWorkingDay.where(is_default: true).order(:week_days)
                       else
                         object&.library_working_days&.order(:week_days)
                       end
        Admin::Entities::LibraryWorkingDays.represent(working_days)
      end
      def division
        division = object&.thana&.district&.division
        return if division.nil?
        {
          id: division.id,
          name: division.name
        }
      end
    end
  end
end

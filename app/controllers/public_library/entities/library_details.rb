# frozen_string_literal: true

module PublicLibrary
  module Entities
    class LibraryDetails < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers
      expose :id
      expose :name
      expose :code
      expose :email
      expose :working_days
      expose :description
      expose :phone
      expose :address
      expose :thana
      expose :district
      expose :lat
      expose :long
      expose :head_of_library
      expose :library_images
      expose :map_iframe

      def name
        locale == :en ? object.name : object.bn_name
      end

      def opening_hour
        {
          start_week_day: ENV['LIBRARY_OPENING_START_DAY'],
          end_week_day: ENV['LIBRARY_OPENING_END_DAY'],
          start_week_hour: ENV['LIBRARY_OPENING_START_HOUR'],
          end_week_hour: ENV['LIBRARY_OPENING_END_HOUR']
        }
      end

      def description
        locale == :en ? object.description : object.bn_description
      end


      def district
        if locale == :en
          object.thana.district.as_json(only: [:id, :name])
        else
          object.thana.district.as_json(only: [:id, :bn_name])
        end
      end

      def thana
        if locale == :en
          object.thana.as_json(only: [:id, :name])
        else
          object.thana.as_json(only: [:id, :bn_name])
        end
      end

      def head_of_library
        library_head = object.staffs.find_by(is_library_head: true)
        {
          name: library_head&.name || '',
          phone: library_head&.phone || '',
          designation: library_head&.designation&.title || ''
        }
      end

      def library_images
        library_images = library_details_images(object.images)
        library_images.nil? ? [] : library_images
      end

      def locale
        options[:locale]
      end

      def working_days
        working_days = if object.is_default_working_days
                         LibraryWorkingDay.where(is_default: true).order(:week_days)
                       else
                         object&.library_working_days&.order(:week_days)
                       end
        Admin::Entities::LibraryWorkingDays.represent(working_days)
      end
    end
  end
end

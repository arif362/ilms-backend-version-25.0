module PublicLibrary
  module Entities
    class SavedAddresses < Grape::Entity
      expose :id
      expose :name
      expose :address_type
      expose :recipient_name
      expose :recipient_phone
      expose :address
      expose :division
      expose :district
      expose :thana
      expose :library
      expose :delivery_area_id
      expose :delivery_area

      def division
        if options[:lan].present?
          PublicLibrary::Entities::Divisions.represent(object.division, lan: options[:lan])
        else
          PublicLibrary::Entities::Divisions.represent(object.division)
        end
      end
      def district
        if options[:lan].present?
          PublicLibrary::Entities::Districts.represent(object.district, lan: options[:lan])
        else
          PublicLibrary::Entities::Districts.represent(object.district)
        end
      end
      def thana
        if options[:lan].present?
          PublicLibrary::Entities::Thanas.represent(object.thana, lan: options[:lan])
        else
          PublicLibrary::Entities::Thanas.represent(object.thana)
        end
      end

      def library
        library = object.thana&.library.present? ? object.thana&.library : object.thana&.district.library_from_district(object.thana)
        PublicLibrary::Entities::LibraryDropdown.represent(library) if library.present?
      end
    end
  end
end
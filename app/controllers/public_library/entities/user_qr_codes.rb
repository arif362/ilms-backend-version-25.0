# frozen_string_literal: true

module PublicLibrary
  module Entities
    class UserQrCodes < Grape::Entity
      expose :id
      expose :library
      expose :services
      expose :expired_at
      expose :qr_code
      expose :user_uniq_id

      def library
        library = object.library
        thana = library&.thana
        district = thana&.district
        {
          name: locale == :en ? library&.name : library&.bn_name,
          district: {
            id: district&.id,
            name: locale == :en ? district&.name : district&.bn_name
          },
          thana: {
            id: thana&.id,
            name: locale == :en ? thana&.name : thana&.bn_name
          }
        }
      end

      def locale
        options[:locale]
      end

      def user_uniq_id
        object.user&.unique_id
      end
    end
  end
end

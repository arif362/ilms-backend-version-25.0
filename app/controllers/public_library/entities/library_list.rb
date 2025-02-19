# frozen_string_literal: true

module PublicLibrary
  module Entities
    class LibraryList < Grape::Entity
      expose :name
      expose :code
      expose :email
      expose :phone
      expose :district
      expose :thana

      def name
        locale == :en ? object.name : object.bn_name
      end

      def district
        district = object&.district
        {
          id: district&.id,
          name: locale == :en ? district&.name : district&.bn_name
        }
      end

      def thana
        thana = object&.thana
        {
          id: thana&.id,
          name: locale == :en ? thana&.name : thana&.bn_name
        }
      end

      def locale
        options[:locale]
      end
    end
  end
end

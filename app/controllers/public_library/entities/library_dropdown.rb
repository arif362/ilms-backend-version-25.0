# frozen_string_literal: true

module PublicLibrary
  module Entities
    class LibraryDropdown < Grape::Entity
      expose :id
      expose :name
      expose :code

      def name
        options[:locale] == :en ? object.name : object.bn_name
      end
    end
  end
end

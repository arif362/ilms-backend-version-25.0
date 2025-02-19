# frozen_string_literal: true

module PublicLibrary
  module Entities
    class EventLibraries < Grape::Entity
      expose :name
      expose :code

      def name
        locale == :en ? object&.name : object&.bn_name
      end

      def code
        object&.code
      end

      def locale
        options[:locale]
      end
    end
  end
end

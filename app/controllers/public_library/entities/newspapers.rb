# frozen_string_literal: true

module PublicLibrary
  module Entities
    class Newspapers < Grape::Entity
      expose :id
      expose :name
      expose :slug
      expose :category
      expose :language

      def name
        locale == :en ? object&.name : object&.bn_name
      end

      def locale
        options[:locale]
      end
    end
  end
end

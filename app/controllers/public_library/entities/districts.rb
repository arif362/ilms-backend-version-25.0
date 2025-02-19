# frozen_string_literal: true

module PublicLibrary
  module Entities
    class Districts < Grape::Entity
      expose :id
      expose :name

      def name
        if options[:lan].present?
          object.name
        else
          locale == :en ? object.name : object.bn_name
        end
      end

      def locale
        options[:locale]
      end
    end
  end
end

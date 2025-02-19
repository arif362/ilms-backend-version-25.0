# frozen_string_literal: true

module PublicLibrary
  module Entities
    class BiblioSubject < Grape::Entity
      expose :id
      expose :name

      def name
        locale == :en ? object&.personal_name : object&.bn_personal_name
      end

      def locale
        options[:locale]
      end
    end
  end
end

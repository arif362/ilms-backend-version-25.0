# frozen_string_literal: true

module PublicLibrary
  module Entities
    class FaqCategories < Grape::Entity
      expose :title

      def title
        locale == :en ? object&.title : object&.bn_title
      end

      def locale
        options[:locale]
      end
    end
  end
end

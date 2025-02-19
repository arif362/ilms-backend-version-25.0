module PublicLibrary
  module Entities
    class BiblioPublications < Grape::Entity
      expose :id
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

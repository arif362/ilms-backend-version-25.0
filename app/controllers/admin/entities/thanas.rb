module Admin
  module Entities
    class Thanas < Grape::Entity
      expose :id
      expose :name
      expose :district


      private

      def district
        if locale == :en
          object.district.as_json(only: [:id, :name])
        else
          object.district.as_json(only: [:id, :bn_name])
        end
      end
      def locale
        options[:locale]
      end
    end
  end
end

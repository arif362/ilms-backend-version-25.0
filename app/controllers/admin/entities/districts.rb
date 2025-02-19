module Admin
  module Entities
    class Districts < Grape::Entity
      expose :id
      expose :name
      expose :division

      private

      def division
        if locale == :en
          object.division.as_json(only: [:id, :name])
        else
          object.division.as_json(only: [:id, :bn_name])
        end
      end
      def locale
        options[:locale]
      end
    end
  end
end

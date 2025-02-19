# frozen_string_literal: true

module Admin
  module Entities
    class Reviews < Grape::Entity
      expose :id
      expose :text
      expose :rating
      expose :status
      expose :biblio
      expose :user

      def biblio
        {
          id: object.biblio&.id,
          title: object.biblio&.title
        }
      end

      def user
        {
          id: object.user&.id,
          full_name: object.user&.full_name
        }
      end
    end
  end
end

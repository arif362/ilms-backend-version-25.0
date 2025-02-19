# frozen_string_literal: true

module Admin
  module Entities
    class DocumentCategories < Grape::Entity

      expose :id
      expose :name
      expose :created_by
      expose :created_at


      private

      def created_by
        {
          id: object.staff.id,
          name: object.staff.name
        }
      end
    end
  end
end

# frozen_string_literal: true

module Admin
  module Entities
    class DocumentIndexes < Grape::Entity

      expose :id
      expose :name
      expose :document_category


      private

      def document_category
        {
          id: object.document_category_id,
          name: object.document_category&.name
        }
      end
    end
  end
end

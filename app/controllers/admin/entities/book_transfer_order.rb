# frozen_string_literal: true

module Admin
  module Entities
    class BookTransferOrder < Grape::Entity
      expose :id
      expose :biblio_title
      expose :library
      expose :user
      expose :status

      def biblio_title
        object.biblio&.title
      end

      def library
        object.library.as_json(only: %i[id code name])
      end

      def user
        object.user.as_json(only: %i[id full_name])
      end
    end
  end
end

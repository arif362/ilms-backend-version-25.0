# frozen_string_literal: true

module Lms
  module Entities
    class BiblioLibraryAvailable < Grape::Entity
      expose :library_id
      expose :library_name
      expose :available_quantity

      def library_name
        object&.library&.name
      end

      def library_id
        object&.library&.id
      end
    end
  end
end

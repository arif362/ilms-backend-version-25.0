# frozen_string_literal: true

module Admin
  module Entities
    class BiblioLibraries < Grape::Entity
      expose :id
      expose :library_name
      expose :available_quantity

      def library_name
        object&.library&.name
      end
    end
  end
end

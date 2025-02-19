# frozen_string_literal: true

module Admin
  module Entities
    class BiblioUpcomingList < Grape::Entity
      format_with(:iso_date, &:to_date)

      expose :id
      expose :title
      expose :isbn
      expose :authors
      expose :quantity, if: { type: :new }
      expose :created_at, format_with: :iso_date, if: { type: :upcoming }

      def authors
        object&.authors&.map do |author|
          {
            id: author&.id,
            name: author&.full_name
          }
        end
      end


      def quantity
        object&.biblio_items&.count
      end
    end
  end
end

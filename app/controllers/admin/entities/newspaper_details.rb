# frozen_string_literal: true

module Admin
  module Entities
    class NewspaperDetails < Grape::Entity

      expose :id
      expose :name
      expose :bn_name
      expose :is_published
      expose :category
      expose :language
      expose :library_newspaper

      def library_newspaper
        library_newspapers = object&.library_newspapers

        library_newspapers.map do |library_newspaper|
          {
            id: library_newspaper.id,
            library_name: library_newspaper.library&.name,
            start_date: library_newspaper.start_date,
            end_date: library_newspaper.end_date
          }
        end
      end
    end
  end
end

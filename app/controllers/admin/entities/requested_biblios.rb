# frozen_string_literal: true

module Admin
  module Entities
    class RequestedBiblios < Grape::Entity
      format_with(:iso_date, &:to_date)

      expose :id
      expose :library
      expose :user
      expose :biblio_title
      expose :authors
      expose :biblio_subjects
      expose :isbn
      expose :created_at, format_with: :iso_date


      def biblio_subjects
        subjects = object&.biblio_subjects&.pluck(:personal_name) || []
        subjects << object&.biblio_subjects_name
        subjects.flatten
      end

      def authors
        authors = object&.authors&.map(&:full_name)
        authors.concat(Array(object&.authors_name))
      end

      def user
        {
          id: object&.user_id,
          name: object&.user&.full_name,
          unique_id: object&.user&.unique_id
        }
      end

      def library
        {
          id: object&.library_id,
          name: object&.library&.name,
          code: object&.library&.code
        }
      end
    end
  end
end

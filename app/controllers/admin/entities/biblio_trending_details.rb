# frozen_string_literal: true

module Admin
  module Entities
    class BiblioTrendingDetails < Grape::Entity
      expose :id
      expose :title
      expose :isbn
      expose :total_count
      expose :biblio_publication, as: :publication, using: Admin::Entities::BiblioPublications
      expose :biblio_subjects, as: :subjects, using: Admin::Entities::BiblioSubjects
      expose :biblio_libraries, using: Admin::Entities::BiblioLibraries

      def total_count
        object.search_count + object.borrow_count + object.read_count
      end
    end
  end
end

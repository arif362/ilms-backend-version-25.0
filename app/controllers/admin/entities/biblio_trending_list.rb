# frozen_string_literal: true

module Admin
  module Entities
    class BiblioTrendingList < Grape::Entity
      expose :id
      expose :title
      expose :isbn
      expose :biblio_publication, as: :publication, using: Admin::Entities::BiblioPublications
      expose :total_count

      def total_count
        object.search_count + object.borrow_count + object.read_count
      end
    end
  end
end

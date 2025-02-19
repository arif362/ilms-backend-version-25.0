module Admin
  module Entities
    class DistributionList < Grape::Entity
      format_with(:iso_date, &:to_date)

      expose :id
      expose :library_id
      expose :created_at, format_with: :iso_date
      expose :book_count
      expose :status


      def book_count
        object&.department_biblio_items&.count
      end
    end
  end
end

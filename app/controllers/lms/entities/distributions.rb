module Lms
  module Entities
    class Distributions < Grape::Entity
      format_with(:iso_date, &:to_date)

      expose :id
      expose :library_id
      expose :created_at, format_with: :iso_date
      expose :updated_at, format_with: :iso_date
      expose :accession_list
      expose :status


      def accession_list
        options[:accession_list]
      end
    end
  end
end

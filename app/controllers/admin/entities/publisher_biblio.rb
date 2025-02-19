# frozen_string_literal: true

module Admin
  module Entities
    class PublisherBiblio < Grape::Entity
      expose :id
      expose :author_name, as: :author
      expose :title
      expose :publisher_name
      expose :publisher_phone
      expose :publisher_address
      expose :publisher_website
      expose :edition
      expose :print
      expose :total_page
      expose :subject
      expose :price
      expose :isbn
      expose :paper_type
      expose :binding_type
      expose :comment
      expose :is_foreign
      expose :is_shortlisted
      expose :quantity
      expose :library_list

      def library_list
        department_biblio_item = DepartmentBiblioItem.where.not(department_biblio_item_status_id: nil, central_accession_no: nil).where(publisher_biblio_id: object.id)
        library = []

        department_biblio_item.each do |item|
          library << {
            department_biblio_item_id: item&.id,
            status: item&.department_biblio_item_status,
            central_accession_no: item&.central_accession_no,
            library_id: item&.library&.id,
            library_name: item&.library&.name
          }
        end
        library
      end

    end
  end
end

# frozen_string_literal: true

module Admin
  module Entities
    class DistributionPublisherBiblios < Grape::Entity
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
      expose :department_biblio_items, using: Admin::Entities::DepartmentBiblioItemList

      def department_biblio_items
        DepartmentBiblioItem.where(publisher_biblio_id: object.id,
                                   distribution_id: options[:id].to_i)
      end

    end
  end
end

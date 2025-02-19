# frozen_string_literal: true

module Admin
  module Entities
    class PublisherBiblioList < Grape::Entity
      expose :id
      expose :memorandum_publisher_id, as: :publisher_id
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
    end
  end
end

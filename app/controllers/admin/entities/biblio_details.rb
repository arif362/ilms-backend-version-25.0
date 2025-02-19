# frozen_string_literal: true

module Admin
  module Entities
    class BiblioDetails < Grape::Entity
      include Admin::Helpers::ImageHelpers

      expose :id
      expose :authors, using: Admin::Entities::Authors
      expose :biblio_subjects, as: :subjects, using: Admin::Entities::BiblioSubjects
      expose :title
      expose :slug
      expose :is_e_biblio, as: :is_ebook
      expose :is_paper_biblio
      expose :remainder_of_title
      expose :copyright_date
      expose :isbn
      expose :original_cataloging_agency
      expose :calaloging_language
      expose :ddc_edition_number
      expose :ddc_classification_number
      expose :ddc_item_number
      expose :biblio_edition
      expose :biblio_publication
      expose :item_type
      expose :physical_details
      expose :other_physical_details
      expose :dimentions
      expose :series_statement_title
      expose :series_statement_volume
      expose :issn
      expose :series_statement
      expose :general_note
      expose :bibliography_note
      expose :contents_note
      expose :topical_term
      expose :full_call_number
      expose :pages
      expose :age_restriction
      expose :corporate_name
      expose :statement_of_responsibility
      expose :edition_statement
      expose :place_of_publication
      expose :date_of_publication
      expose :extent
      expose :average_rating
      expose :total_reviews
      expose :image_url
      expose :preview_file_url
      expose :full_ebook_file_url
      expose :is_published

      def biblio_edition
        biblio_edition = BiblioEdition.find_by(id: object.biblio_edition_id)
        {
          id: biblio_edition&.id,
          title: biblio_edition&.title
        }
      end
      def biblio_publication
        biblio_publication = BiblioPublication.find_by(id: object.biblio_publication_id)
        {
          id: biblio_publication&.id,
          title: biblio_publication&.title
        }
      end

      def image_url
        mobile_large_image(object.image)
      end

      def item_type
        {
          id: object&.item_type&.id,
          title: object&.item_type&.title
        }
      end

      def preview_file_url
        image_path(object.preview)
      end
    end
  end
end

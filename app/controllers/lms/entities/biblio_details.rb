# frozen_string_literal: true

module Lms
  module Entities
    class BiblioDetails < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :id
      expose :authors
      expose :editors
      expose :translators
      expose :contributors
      expose :subjects
      expose :title
      expose :slug
      expose :item_type
      expose :is_e_biblio
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
      expose :total_review
      expose :created_by_id
      expose :updated_by_id
      expose :created_at
      expose :updated_at
      expose :image_url
      expose :preview_file_url
      expose :full_ebook_file_url
      expose :full_pdf_file_url
      expose :table_of_context
      expose :table_of_content_file_url

      def authors
        Author.where(id: object.author_biblios.where(responsibility: 'Author').map(&:author_id))
      end

      def subjects
        BiblioSubject.where(id: object.biblio_subject_biblios.map(&:biblio_subject_id))
      end

      def editors
        Author.where(id: object.author_biblios.where(responsibility: 'Editor').map(&:author_id))
      end

      def translators
        Author.where(id: object.author_biblios.where(responsibility: 'Translator').map(&:author_id))
      end

      def contributors
        Author.where(id: object.author_biblios.where(responsibility: 'Contributor').map(&:author_id))
      end

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

      def average_rating
        total_review != 0 ? (object.reviews.approved.sum(:rating) / total_review.to_f).round(1) : 0
      end

      def total_review
        object.reviews.approved.count
      end

      def image_url
        mobile_large_image(object.image)
      end

      def item_type
        object.item_type&.title
      end

      def preview_file_url
        image_path(object.preview)
      end

      def full_ebook_file_url
        image_path(object.full_ebook)
      end

      def table_of_content_file_url
        image_path(object.table_of_content)
      end
    end
  end
end

# frozen_string_literal: true

module PublicLibrary
  module Entities
    class BiblioDetails < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :title
      expose :slug
      expose :is_wishlisted
      expose :authors, using: PublicLibrary::Entities::Authors
      expose :biblio_subjects, as: :subjects, using: PublicLibrary::Entities::BiblioSubjects
      expose :is_e_biblio, as: :is_ebook
      expose :is_paper_biblio
      expose :series_statement_volume
      expose :remainder_of_title
      expose :isbn
      expose :biblio_edition
      expose :biblio_publication
      expose :full_call_number
      expose :pages
      expose :date_of_publication
      expose :average_rating
      expose :total_review
      expose :image_url
      expose :preview_ebook_file_url
      expose :full_ebook_file_url
      expose :full_pdf_file_url
      expose :calaloging_language
      expose :item_type



      def date_of_publication
        object.date_of_publication&.strftime('%d/%m/%Y')
      end

      def biblio_edition
        BiblioEdition.find_by(id: object.biblio_edition_id)&.title
      end

      def biblio_publication
        publication = BiblioPublication.find_by(id: object.biblio_publication_id)
        locale == :en ? publication&.title : publication&.bn_title
      end

      def average_rating
        total_review != 0 ? (object.reviews.approved.sum(:rating) / total_review.to_f).round(1) : 0
      end

      def total_review
        object.reviews.approved.count
      end

      def image_url
        web_images = { desktop_image: desktop_cart_image(object.image), tab_image: tab_cart_image(object.image) }
        options[:request_source] == :app ? mobile_large_image(object.image) : web_images
      end

      def locale
        options[:locale]
      end

      def current_user
        options[:current_user]
      end

      def is_wishlisted
        object.wishlisted?(current_user)
      end

    end
  end
end

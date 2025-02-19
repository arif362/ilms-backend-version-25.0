# frozen_string_literal: true

module Lms
  module Entities
    class RequestedBiblioDetails < Grape::Entity
      include Lms::Helpers::ImageHelpers

      expose :id
      expose :biblio_title
      expose :authors
      expose :biblio_subjects
      expose :isbn
      expose :publication
      expose :edition
      expose :volume
      expose :image

      def biblio_subjects
        biblio_subjects = object&.biblio_subjects&.pluck(:personal_name)
        biblio_subjects.concat(object&.biblio_subjects_name)
      end

      def image
        web_image = {
          desktop_image: desktop_cart_image(object&.image),
          tab_image: tab_cart_image(object&.image)
        }
        options[:request_source] == :app ? mobile_cart_image(object&.image) : web_image
      end

      def authors
        authors = object&.authors&.map(&:full_name)
        authors.concat(object&.authors_name)
      end
    end
  end
end

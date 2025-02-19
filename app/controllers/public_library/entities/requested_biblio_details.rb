# frozen_string_literal: true

module PublicLibrary
  module Entities
    class RequestedBiblioDetails < Grape::Entity
      include PublicLibrary::Helpers::ImageHelpers

      expose :id
      expose :biblio_title
      expose :authors
      expose :biblio_subjects
      expose :isbn
      expose :publication
      expose :edition
      expose :volume
      expose :image
      expose :possible_availability_at

      def biblio_subjects
        biblio_subjects = if locale == :en
                            object&.biblio_subjects&.pluck(:personal_name)
                          else
                            object&.biblio_subjects&.pluck(:bn_personal_name)
                          end
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
        authors = if locale == :en
                    object&.authors&.map(&:full_name)
                  else
                    object&.authors&.map(&:bn_full_name)
                  end
        authors.concat(object&.authors_name)
      end

      def locale
        options[:locale]
      end
    end
  end
end

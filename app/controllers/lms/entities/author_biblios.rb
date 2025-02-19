# frozen_string_literal: true

module Lms
  module Entities
    class AuthorBiblios < Grape::Entity
      expose :id
      expose :author
      expose :responsibility

      def author
        Lms::Entities::AuthorDetails.represent(object.author)
      end
    end
  end
end

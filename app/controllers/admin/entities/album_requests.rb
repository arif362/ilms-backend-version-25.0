# frozen_string_literal: true

module Admin
  module Entities
    class AlbumRequests < Grape::Entity

      expose :id
      expose :title
      expose :bn_title
      expose :album_type
      expose :status
      expose :library

      def library
        library = object&.library
        {
          id: library&.id,
          code: library&.code
        }
      end
    end
  end
end

# frozen_string_literal: true

module Admin
  module Entities
    class BiblioItems < Grape::Entity
      expose :id
      expose :title
      expose :accession_no
      expose :central_accession_no
      expose :library
      expose :current_circulation_status

      def title
        object.biblio.title
      end

      def current_circulation_status
        object&.circulations&.last&.circulation_status&.borrowed? ? 'Borrowed' : 'Available'
      end

      def library
        object.library.as_json(only: %i[id name])
      end
    end
  end
end

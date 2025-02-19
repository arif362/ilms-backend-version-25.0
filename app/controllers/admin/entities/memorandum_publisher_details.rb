# frozen_string_literal: true

module Admin
  module Entities
    class MemorandumPublisherDetails < Grape::Entity

      expose :id
      expose :memorandum
      expose :publisher, using: Admin::Entities::Publishers
      expose :is_shortlisted
      expose :is_final_submitted
      expose :publisher_biblios
      expose :submitted_at

      def memorandum
        memorandum = object&.memorandum
        {
          id: memorandum&.id,
          memorandum_no: memorandum&.memorandum_no
        }
      end

      def publisher_biblios
        Admin::Entities::PublisherBiblioDetails.represent(object.publisher_biblios, expose_memorandum: false)
      end
    end
  end
end

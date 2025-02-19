# frozen_string_literal: true

module PublicLibrary
  module Entities
    class MemorandumPublishers < Grape::Entity

      expose :id
      expose :memorandum
      expose :track_no

      def memorandum
        memorandum = object&.memorandum
        {
          id: memorandum&.id,
          memorandum_no: memorandum&.memorandum_no,
          tender_session: memorandum&.tender_session
        }
      end
    end
  end
end

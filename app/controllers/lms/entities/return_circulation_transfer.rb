# frozen_string_literal: true

module Lms
  module Entities
    class ReturnCirculationTransfer< Grape::Entity
      expose :id
      expose :biblio_item_id
      expose :sender_library_id
      expose :receiver_library_id
      expose :return_circulation_status_id
    end
  end
end

# frozen_string_literal: true

module Lms
  module Entities
    class IntLibExtension < Grape::Entity

      expose :id
      expose :status
      expose :extend_end_date
      expose :sender_library
      expose :receiver_library
      expose :created_by_id
      expose :created_by_type
      expose :updated_by_id
      expose :updated_by_type
    end

    def sender_library
      sender_library = object.sender_library
      {
        id: sender_library.id,
        name: sender_library.name
      }
    end

    def receiver_library
      receiver_library = object.receiver_library
      {
        id: receiver_library.id,
        name: receiver_library.name
      }
    end
  end
end

# frozen_string_literal: true

module Lms
  module Entities
    class ExtendRequests < Grape::Entity

      expose :id
      expose :status
      expose :reason
      expose :member_id
      expose :created_by_id
      expose :created_by_type
      expose :updated_by_id
      expose :updated_by_type
      expose :circulation, using: Lms::Entities::Circulations
    end
  end
end

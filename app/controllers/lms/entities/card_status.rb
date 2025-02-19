# frozen_string_literal: true

module Lms
  module Entities
    class CardStatus < Grape::Entity
      expose :id
      expose :status_key
      expose :lms_status
    end
  end
end

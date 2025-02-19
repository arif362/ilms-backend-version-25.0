# frozen_string_literal: true

module Lms
  module Entities
    class ReturnCirculations< Grape::Entity
      expose :circulation, using: Lms::Entities::Circulations
      expose :return_circulation_transfer, using: Lms::Entities::ReturnCirculationTransfer
    end
  end
end

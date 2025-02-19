# frozen_string_literal: true
module PublicLibrary
  module Entities
    class CurrentCirculationFine < Grape::Entity
      expose :id
      expose :return_at
      expose :calculate_fine, as: :fine_amount
    end
  end
end

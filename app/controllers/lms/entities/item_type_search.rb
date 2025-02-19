# frozen_string_literal: true

module Lms
  module Entities
    class ItemTypeSearch < Grape::Entity
      expose :id
      expose :title
    end
  end
end

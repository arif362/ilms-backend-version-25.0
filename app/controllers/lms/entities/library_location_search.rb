# frozen_string_literal: true

module Lms
  module Entities
    class LibraryLocationSearch < Grape::Entity
      expose :id
      expose :code
      expose :name
      expose :location_type
    end
  end
end

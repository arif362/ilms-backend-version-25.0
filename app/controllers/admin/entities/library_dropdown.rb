# frozen_string_literal: true

module Admin
  module Entities
    class LibraryDropdown < Grape::Entity
      expose :id
      expose :name
      expose :code
    end
  end
end

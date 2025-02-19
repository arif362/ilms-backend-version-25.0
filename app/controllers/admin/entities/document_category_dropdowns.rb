# frozen_string_literal: true

module Admin
  module Entities
    class DocumentCategoryDropdowns < Grape::Entity

      expose :id
      expose :name

    end
  end
end

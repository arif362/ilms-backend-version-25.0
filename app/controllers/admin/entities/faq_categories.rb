# frozen_string_literal: true

module Admin
  module Entities
    class FaqCategories < Grape::Entity

      expose :id
      expose :title
      expose :bn_title
    end
  end
end

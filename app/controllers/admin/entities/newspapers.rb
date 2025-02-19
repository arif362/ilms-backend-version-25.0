# frozen_string_literal: true

module Admin
  module Entities
    class Newspapers < Grape::Entity

      expose :id
      expose :name
      expose :bn_name
      expose :is_published
      expose :category
      expose :language
    end
  end
end

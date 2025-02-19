# frozen_string_literal: true

module Admin
  module Entities
    class PageTypes < Grape::Entity
      expose :id
      expose :title

      def title
        object.title.titleize
      end
    end
  end
end


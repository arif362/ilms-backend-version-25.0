# frozen_string_literal: true

module Admin
  module Entities
    class Notices < Grape::Entity
      expose :id
      expose :title
      expose :is_published
      expose :published_date
    end
  end
end

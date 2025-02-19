# frozen_string_literal: true

module Admin
  module Entities
    class Events < Grape::Entity
      expose :id
      expose :title
      expose :start_date
      expose :end_date
      expose :is_published
      expose :is_local
    end
  end
end

# frozen_string_literal: true

module Lms
  module Entities
    class Events < Grape::Entity
      expose :id
      expose :title
      expose :bn_title
      expose :start_date
      expose :end_date
      expose :is_published
    end
  end
end

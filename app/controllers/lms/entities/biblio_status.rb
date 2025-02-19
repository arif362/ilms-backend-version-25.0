# frozen_string_literal: true

module Lms
  module Entities
    class BiblioStatus < Grape::Entity
      expose :id
      expose :title
      expose :status_type
      expose :created_at
      expose :updated_at
    end
  end
end

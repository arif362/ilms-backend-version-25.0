# frozen_string_literal: true

module Lms
  module Entities
    class BiblioStatusSearch < Grape::Entity
      expose :id
      expose :title
      expose :status_type
    end
  end
end

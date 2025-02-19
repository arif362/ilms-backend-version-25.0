# frozen_string_literal: true

module Lms
  module Entities
    class BiblioEditionSearch < Grape::Entity
      expose :id
      expose :title
    end
  end
end

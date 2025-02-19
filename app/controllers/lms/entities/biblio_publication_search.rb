# frozen_string_literal: true

module Lms
  module Entities
    class BiblioPublicationSearch < Grape::Entity
      expose :id
      expose :title
      expose :bn_title
    end
  end
end

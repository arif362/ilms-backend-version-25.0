# frozen_string_literal: true

module Admin
  module Entities
    class BiblioSubjects < Grape::Entity
      expose :id
      expose :personal_name
      expose :bn_personal_name
    end
  end
end

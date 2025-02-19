# frozen_string_literal: true

module Lms
  module Entities
    class Authors < Grape::Entity
      expose :id
      expose :full_name
      expose :bn_full_name
      expose :title
      expose :dob
    end
  end
end

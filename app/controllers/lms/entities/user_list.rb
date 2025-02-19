# frozen_string_literal: true

module Lms
  module Entities
    class UserList < Grape::Entity
      expose :id
      expose :full_name
      expose :unique_id
      expose :phone
      expose :gender
      expose :dob
      expose :email
    end
  end
end

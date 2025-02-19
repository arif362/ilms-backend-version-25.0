module Lms
  module Entities
    class Guests < Grape::Entity
      expose :id
      expose :name
      expose :email
      expose :phone
      expose :dob
      expose :gender
      expose :library_id
      expose :token
    end
  end
end

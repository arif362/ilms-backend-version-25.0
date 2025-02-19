module Lms
  module Entities
    class TmpUsers < Grape::Entity
      expose :id, as: :tmp_id
      expose :full_name
      expose :email
      expose :dob
      expose :phone
    end
  end
end

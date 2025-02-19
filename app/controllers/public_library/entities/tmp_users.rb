module PublicLibrary
  module Entities
    class TmpUsers < Grape::Entity
      expose :id, as: :tmp_id
      expose :full_name
      expose :email
      expose :dob
      expose :gender
      expose :is_otp_verified
      expose :phone
    end
  end
end

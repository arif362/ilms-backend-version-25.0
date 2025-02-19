module Lms
  module Entities
    class ReturnDropdowns < Grape::Entity
      expose :id
      expose :lms_status
      expose :status_key
    end
  end
end

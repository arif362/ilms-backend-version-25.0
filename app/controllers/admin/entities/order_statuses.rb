module Admin
  module Entities
    class OrderStatuses < Grape::Entity
      expose :id
      expose :status_key
      expose :admin_status
    end
  end
end

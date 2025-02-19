module Admin
  module Entities
    class CardStatus < Grape::Entity
      expose :id
      expose :status_key
      expose :admin_status
    end
  end
end

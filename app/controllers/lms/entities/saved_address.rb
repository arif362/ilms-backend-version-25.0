module Lms
  module Entities
    class SavedAddress < Grape::Entity
      expose :id
      expose :name
      expose :address_type
      expose :recipient_name
      expose :recipient_phone
      expose :address
      expose :division_id
      expose :district_id
      expose :thana_id
    end
  end
end
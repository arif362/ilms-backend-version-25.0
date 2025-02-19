# frozen_string_literal: true

module ThreePs
  module Entities
    class LibraryCards < Grape::Entity
      expose :id
      expose :name
      expose :barcode
      expose :recipient_name
      expose :recipient_phone
      expose :address_type
      expose :division, using: ThreePs::Entities::Divisions
      expose :district, using: ThreePs::Entities::Districts
      expose :thana, using: ThreePs::Entities::Thanas
      expose :card_status
      expose :delivery_type
      expose :note
      expose :smart_card_number
    end
  end
end

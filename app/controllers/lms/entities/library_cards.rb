# frozen_string_literal: true

module Lms
  module Entities
    class LibraryCards < Grape::Entity
      expose :id
      expose :member
      expose :name
      expose :issue_date
      expose :expire_date
      expose :membership_category
      expose :barcode
      expose :recipient_name
      expose :recipient_phone
      expose :address_type
      expose :division, using: Lms::Entities::Divisions
      expose :district, using: Lms::Entities::Districts
      expose :thana, using: Lms::Entities::Thanas
      expose :card_status
      expose :delivery_type
      expose :is_active
      expose :is_lost
      expose :is_damaged
      expose :note
      expose :smart_card_number
    end
  end
end

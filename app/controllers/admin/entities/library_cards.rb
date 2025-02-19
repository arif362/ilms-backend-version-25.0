# frozen_string_literal: true

module Admin
  module Entities
    class LibraryCards < Grape::Entity
      expose :id
      expose :barcode
      expose :issued_library, using: Admin::Entities::Libraries
      expose :member, using: Admin::Entities::MemberList
      expose :name
      expose :issue_date
      expose :created_at, as: :requested_at
      expose :expire_date
      expose :membership_category
      expose :card_status, using: Admin::Entities::CardStatuses
      expose :is_active
      expose :is_lost
      expose :is_damaged
      expose :delivery_type
    end
  end
end

# frozen_string_literal: true

module PublicLibrary
  module Entities
    class LibraryCards < Grape::Entity
      expose :id
      expose :barcode
      expose :issued_library, using: PublicLibrary::Entities::LibraryList
      expose :name
      expose :issue_date
      expose :expire_date
      expose :membership_category
      expose :card_status, using: PublicLibrary::Entities::CardStatuses
      expose :is_active
      expose :is_lost
      expose :is_damaged
    end
  end
end

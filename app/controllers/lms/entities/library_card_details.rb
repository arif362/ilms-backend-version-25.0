# frozen_string_literal: true

module Lms
  module Entities
    class LibraryCardDetails < Grape::Entity
      expose :id
      expose :barcode
      expose :issued_library, using: PublicLibrary::Entities::LibraryList
      expose :name
      expose :issue_date
      expose :expire_date
      expose :membership_category
      expose :card_status, using: PublicLibrary::Entities::CardStatuses
      expose :amount
      expose :is_active
      expose :is_lost
      expose :is_damaged
      expose :is_expired
      expose :delivery_type
      expose :address_type
      expose :recipient_name
      expose :recipient_phone
      expose :delivery_address
      expose :division, using: PublicLibrary::Entities::Divisions
      expose :district, using: PublicLibrary::Entities::Districts
      expose :thana, using: PublicLibrary::Entities::Thanas
      expose :gd_image_url
      expose :damaged_card_image_url
      expose :reference_card, using: PublicLibrary::Entities::RefLibraryCards

      def gd_image_url
        return nil unless object.gd_image.attached?

        Rails.application.routes.url_helpers.rails_blob_path(object.gd_image, only_path: true)
      end

      def damaged_card_image_url
        return nil unless object.damaged_card_image.attached?

        Rails.application.routes.url_helpers.rails_blob_path(object.damaged_card_image, only_path: true)
      end

      def amount
        ENV['LOST_CARD_AMOUNT'].to_i
      end
    end
  end
end

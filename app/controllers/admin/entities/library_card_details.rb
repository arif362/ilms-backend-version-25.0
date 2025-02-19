# frozen_string_literal: true

module Admin
  module Entities
    class LibraryCardDetails < Grape::Entity
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
      expose :address_type
      expose :recipient_name
      expose :recipient_phone
      expose :delivery_address
      expose :division, using: Admin::Entities::Divisions
      expose :district, using: Admin::Entities::Districts
      expose :thana, using: Admin::Entities::Thanas
      expose :gd_image_url
      expose :damaged_card_image_url
      expose :reference_card, using: Admin::Entities::RefLibraryCards

      def gd_image_url
        return nil unless object.gd_image.attached?
        Rails.application.routes.url_helpers.rails_blob_path(object.gd_image, only_path: true)
      end

      def damaged_card_image_url
        return nil unless object.damaged_card_image.attached?
        Rails.application.routes.url_helpers.rails_blob_path(object.damaged_card_image, only_path: true)
      end
    end
  end
end

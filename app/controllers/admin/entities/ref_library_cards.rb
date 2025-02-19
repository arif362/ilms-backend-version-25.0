# frozen_string_literal: true

module Admin
  module Entities
    class RefLibraryCards < Grape::Entity
      expose :id
      expose :barcode
      expose :issued_library, using: Admin::Entities::Libraries
      expose :name
      expose :issue_date
      expose :expire_date
      expose :membership_category
      expose :card_status, using: Admin::Entities::CardStatuses
      expose :is_active
      expose :is_lost
      expose :is_damaged
      expose :gd_image_url
      expose :damaged_card_image_url

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

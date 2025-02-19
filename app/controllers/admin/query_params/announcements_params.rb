# frozen_string_literal: true

module Admin
  module QueryParams
    module AnnouncementsParams
      extend ::Grape::API::Helpers

      params :announcement_create_params do
        requires :title, type: String, allow_blank: false
        requires :bn_title, type: String, allow_blank: false
        requires :description, type: String, allow_blank: false
        requires :bn_description, type: String, allow_blank: false
        optional :notification_type, type: String, allow_blank: false, values: Announcement.notification_types.keys
        requires :announcement_for, type: String, allow_blank: false, values: Announcement.announcement_fors.keys
        optional :is_published, type: Boolean, allow_blank: false, values: [true, false]
      end
      params :announcement_update_params do
        requires :title, type: String, allow_blank: false
        requires :bn_title, type: String, allow_blank: false
        requires :description, type: String, allow_blank: false
        requires :bn_description, type: String, allow_blank: false
        optional :notification_type, type: String, allow_blank: false, values: Announcement.notification_types.keys
        requires :announcement_for, type: String, allow_blank: false, values: Announcement.announcement_fors.keys
        optional :is_published, type: Boolean, allow_blank: false, values: [true, false]
      end
    end
  end
end

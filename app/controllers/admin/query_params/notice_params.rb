# frozen_string_literal: true

module Admin
  module QueryParams
    module NoticeParams
      extend ::Grape::API::Helpers
      params :notice_create_params do
        requires :title, type: String, allow_blank: false
        requires :bn_title, type: String, allow_blank: false
        optional :published_date, type: DateTime
        optional :description, type: String, allow_blank: false
        optional :bn_description, type: String, allow_blank: false
        optional :is_published, type: Boolean, allow_blank: false
        optional :document_file, type: File
        optional :notice_type, type: String, allow_blank: false, values: Notice.notice_types.keys
      end

      params :notice_update_params do
        requires :title, type: String, allow_blank: false
        requires :bn_title, type: String, allow_blank: false
        optional :published_date, type: DateTime
        optional :description, type: String, allow_blank: false
        optional :bn_description, type: String, allow_blank: false
        optional :is_published, type: Boolean, allow_blank: false
        optional :document_file, type: File
        optional :notice_type, type: String, allow_blank: false, values: Notice.notice_types.keys
      end
    end
  end
end

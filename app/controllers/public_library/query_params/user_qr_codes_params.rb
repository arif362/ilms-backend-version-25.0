# frozen_string_literal: true

module PublicLibrary
  module QueryParams
    module UserQrCodesParams
      extend ::Grape::API::Helpers
      params :user_qr_code_create_params do
        requires :services, type: Array[String], allow_blank: false, values: LibraryEntryLog::SERVICE_NAMES
        requires :library_code, type: String
        optional :name, type: String, allow_blank: false
        optional :phone, type: String, allow_blank: false
        optional :email, type: String, allow_blank: false
        optional :gender, type: String, values: %w[male female other], allow_blank: false
        optional :dob, type: Date, allow_blank: false
      end
    end
  end
end

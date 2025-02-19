# frozen_string_literal: true

module Lms
  module QueryParams
    module LibraryEntryLogParams
      extend ::Grape::API::Helpers
      params :entry_log_create_params do
        requires :entryable_id, type: Integer, allow_blank: false
        requires :entryable_type, type: String, allow_blank: false, values: %w[User Guest Member]
        requires :services, type: Array[String], allow_blank: false, values: LibraryEntryLog::SERVICE_NAMES
      end
    end
  end
end

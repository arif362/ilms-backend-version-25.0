# frozen_string_literal: true

module Lms
  class LibraryEntryLogs < Lms::Base
    helpers Lms::QueryParams::LibraryEntryLogParams
    resources :library_entry_logs do
      desc 'Create Entry Log'
      params do
        use :entry_log_create_params
      end

      post do
        entryable = params[:entryable_type].constantize.find_by(id: params[:entryable_id])
        unless entryable.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Entry User/Guest not found' },
                                  @current_library, false)
          error!('Entry User/Guest not found', HTTP_CODE[:NOT_FOUND])
        end

        entry_log = LibraryEntryLog.new(declared(params).merge(library_id: @current_library.id))
        if entry_log.save!
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  @current_library, true)
          Lms::Entities::LibraryEntryLogs.represent(entry_log)
        end
      end
    end
  end
end

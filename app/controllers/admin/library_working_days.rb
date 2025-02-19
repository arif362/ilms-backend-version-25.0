# frozen_string_literal: true

module Admin
  class LibraryWorkingDays < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    helpers Admin::QueryParams::LibraryParams

    resources :library_working_days do
      desc 'Return list of library_working_days'
      get do

        working_days = LibraryWorkingDay.where(is_default: true).order(:week_days)

        Admin::Entities::LibraryWorkingDays.represent(working_days)
      end
    end
  end
end

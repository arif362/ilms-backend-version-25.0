# frozen_string_literal: true

module Admin
  module Entities
    class LibraryWorkingDays < Grape::Entity
      format_with(:capitalize, &:capitalize)

      expose :id
      expose :week_days, format_with: :capitalize
      expose :is_holiday
      expose :start_time
      expose :end_time
    end
  end
end

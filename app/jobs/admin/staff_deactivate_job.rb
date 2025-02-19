# frozen_string_literal: true

module Admin
  class StaffDeactivateJob < ApplicationJob
    queue_as :default

    def perform(staff)
      Admin::StaffDeactivate.call(staff:)
    end
  end
end

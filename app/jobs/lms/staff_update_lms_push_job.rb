
module Lms
  class StaffUpdateLmsPushJob < ApplicationJob
    queue_as :default

    def perform(staff)
      Lms::StaffUpdate.call(staff:)
    end
  end
end

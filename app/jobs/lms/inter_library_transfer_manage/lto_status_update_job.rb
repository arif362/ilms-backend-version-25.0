# frozen_string_literal: true

module Lms
  module InterLibraryTransferManage
    class LtoStatusUpdateJob < ApplicationJob
      queue_as :default

      def perform(lto, status, library_type, user_able)
        Lms::InterLibraryTransferManage::LtoStatusUpdate.call(lto:, status:, library_type:, user_able:)
      end
    end
  end
end

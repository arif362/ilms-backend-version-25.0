# frozen_string_literal: true

module Lms
  module InterLibraryTransferManage
    class LtoReturnStatusUpdateJob < ApplicationJob
      queue_as :default

      def perform(lto, status, library_type, user_able)
        Lms::InterLibraryTransferManage::LtoReturnStatusUpdate.call(lto:, status:, library_type:, user_able:)
      end
    end
  end
end

# frozen_string_literal: true

module Lms
  module InterLibraryTransferManage
    class CreateLtoReturnJob < ApplicationJob
      queue_as :default

      def perform(lto_return, user_able)
        Lms::InterLibraryTransferManage::CreateLtoReturn.call(lto_return:, user_able:)
      end
    end
  end
end

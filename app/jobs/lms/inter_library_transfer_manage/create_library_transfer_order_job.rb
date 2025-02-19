# frozen_string_literal: true

module Lms
  module InterLibraryTransferManage
    class CreateLibraryTransferOrderJob < ApplicationJob
      queue_as :default

      def perform(lto, user_able)
        Lms::InterLibraryTransferManage::CreateLibraryTransferOrder.call(lto:, user_able:)
      end
    end
  end
end

# frozen_string_literal: true

module Lms
  module InterLibraryTransferManage
    class CreateBookTransferOrderJob < ApplicationJob
      queue_as :default

      def perform(request_details, user_able)
        Lms::InterLibraryTransferManage::CreateBookTransferOrder.call(request_details:, user_able:)
      end
    end
  end
end

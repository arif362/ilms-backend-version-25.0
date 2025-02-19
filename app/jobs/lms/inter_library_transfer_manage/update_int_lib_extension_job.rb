# frozen_string_literal: true

module Lms
  module InterLibraryTransferManage
    class UpdateIntLibExtensionJob < ApplicationJob
      queue_as :default

      def perform(ile, user_able)
        Lms::InterLibraryTransferManage::UpdateIntLibExtension.call(ile:, user_able:)
      end
    end
  end
end

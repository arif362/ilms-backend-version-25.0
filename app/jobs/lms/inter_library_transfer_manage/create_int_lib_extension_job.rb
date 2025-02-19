# frozen_string_literal: true

module Lms
  module InterLibraryTransferManage
    class CreateIntLibExtensionJob < ApplicationJob
      queue_as :default

      def perform(ile, user_able)
        Lms::InterLibraryTransferManage::CreateIntLibExtension.call(ile:, user_able:)
      end
    end
  end
end

# frozen_string_literal: true

module Lms
  class ItemtypeJob < ApplicationJob
    queue_as :default

    def perform(item, action_type)
      Lms::Itemtypes.call(item:, action_type:)
    end
  end
end

module Lms
  class NewspaperJob < ApplicationJob
    queue_as :default

    def perform(newspaper)
      Lms::NewspaperService.call(newspaper:)
    end
  end
end

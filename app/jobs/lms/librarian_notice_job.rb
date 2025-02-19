module Lms
  class LibrarianNoticeJob < ApplicationJob
    queue_as :default

    def perform(notice)
      Lms::LibrarianNotices.call(notice:)
    end
  end
end

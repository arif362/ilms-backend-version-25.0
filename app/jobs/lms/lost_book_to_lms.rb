
module Lms
  class LostBookToLms < ApplicationJob
    queue_as :default

    def perform(circulation)
      Lms::LostBookLms.call(circulation:)
    end
  end
end

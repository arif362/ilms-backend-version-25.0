class LmsLogJob < ApplicationJob
  queue_as :default

  def perform(*request, response, user, status)
    LmsLog.add_log(request, response, user, status)
  end
end

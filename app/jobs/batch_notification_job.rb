# frozen_string_literal: true

class BatchNotificationJob < ApplicationJob
  queue_as :default

  def perform(args)
    notificationable = args[:notificationable]
    permission = args[:permission] || nil
    message = args[:message] || ''
    message_bn = args[:message_bn] || ''
    return unless permission.present?

    NotificationManagement::CreateBatchNotification.call(notificationable:,
                                                         permission:,
                                                         message:,
                                                         message_bn:)
  end
end

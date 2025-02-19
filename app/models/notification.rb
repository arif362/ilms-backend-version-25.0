class Notification < ApplicationRecord
  validates :title, :bn_title, :message, :message_bn, presence: true
  belongs_to :notificationable, polymorphic: true, optional: true
  belongs_to :notifiable, polymorphic: true, optional: true

  scope :unread, -> { where(is_read: false) }

  def self.create_notification(notificationable, notifiable, title, bn_title, message, message_bn)
    notificationable.notifications.build(
      notifiable: notifiable,
      title: title,
      bn_title: bn_title,
      message: message,
      message_bn: message_bn
    )
  end
end

# frozen_string_literal: true
class CreateNotificationJob < ApplicationJob
  queue_as :default

  def perform(announcement)

    @announcement = announcement

    users = []

    users.concat(User.all) if @announcement.users?

    users.concat(Member.all) if @announcement.members?

    users.concat(Member.general.all) if @announcement.general?

    users.concat(Member.student.all) if @announcement.student?

    users.concat(Member.child.all) if @announcement.child?

    users.each do |user|
      notification_creation(@announcement, user)
    end
  end

  def notification_creation(announcement, user)
    announcement.notifications.create(
      notifiable_type: announcement.announcement_for == 'users' ? User : Member,
      notifiable_id: user.id,
      message: announcement.description,
      message_bn: announcement.bn_description,
      title: announcement.title,
      bn_title: announcement.bn_title
    )
  end
end

# frozen_string_literal: true

class Announcement < ApplicationRecord
  audited
  has_many :notifications, as: :notificationable, dependent: :destroy
  validates :title, :bn_title, :notification_type, presence: true
  validates :bn_description, presence: true, if: :is_description_present?


  def is_description_present?
    description.present?
  end

  enum announcement_for: {
    members: 0,
    users: 1,
    general: 2,
    student: 3,
    child: 4
  }

  enum notification_type: {
    both: 0,
    app: 1,
    push: 2
  }
end

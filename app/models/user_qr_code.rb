# frozen_string_literal: true

class UserQrCode < ApplicationRecord
  serialize :services, Array

  belongs_to :user, optional: true
  belongs_to :library

  validates_uniqueness_of :services, scope: %i[user_id library_id], conditions: -> { where('expired_at >= ?', DateTime.now) }

  scope :active, -> { where('expired_at >= ?', DateTime.now) }
  scope :inactive, -> { where('expired_at < ?', DateTime.now) }
end

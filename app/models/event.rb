# frozen_string_literal: true

class Event < ApplicationRecord
  include SearchableEngBanglaTitle
  audited except: %i[details bn_details]
  serialize :registration_fields, Array
  serialize :competition_info, JSON
  REGISTRATION_FIELDS = %w[name phone identity_type identity_number email address father_name mother_name profession].freeze
  has_many :event_libraries, dependent: :restrict_with_exception
  has_many :libraries, through: :event_libraries
  has_many :event_registrations
  has_many :users, through: :event_registrations
  has_many :albums, dependent: :restrict_with_exception
  has_many :notifications, as: :notificationable, dependent: :destroy
  scope :not_deleted, -> { where(is_deleted: false) }
  scope :published, -> { where(is_published: true, is_deleted: false) }

  validates :title, :bn_title, :details, :bn_details, :start_date, :end_date, presence: true
  validates_uniqueness_of :slug, conditions: -> { where(is_deleted: false) }
  validates :end_date, comparison: { greater_than_or_equal_to: :start_date }, if: :end_date_changed?
  validates :registration_last_date,
            comparison: { less_than_or_equal_to: :end_date, message: 'must be less than or equal to the end date' },
            if: -> { registration_last_date_changed? && is_registerable }
  validates :email, allow_blank: true,
                    format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/, message: 'format is invalid' }
  validates :phone, allow_blank: true,
                    length: { is: 11 }, presence: true,
                    numericality: { only_integer: true },
                    format: { with: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/, message: 'is invalid' }

  has_one_attached :image do |attachable|
    attachable.variant :desktop_large, resize_to_limit: [1240, 480]
    attachable.variant :desktop_cart, resize_to_limit: [1240, 480]
    attachable.variant :tab_large, resize_to_limit: [620, 240]
    attachable.variant :tab_cart, resize_to_limit: [620, 240]
    attachable.variant :mobile_large, resize_to_limit: [500, 200]
    attachable.variant :mobile_cart, resize_to_limit: [500, 200]
  end

  accepts_nested_attributes_for :event_libraries, allow_destroy: true, reject_if: :all_blank

  before_create :set_slug

  after_commit on: :create do
    Lms::EventJob.perform_later(self, 'created') unless is_local?
  end

  after_commit on: :update do

    Lms::EventJob.perform_later(self, 'updated') if is_deleted == false
    Lms::EventJob.perform_later(self, 'deleted') if is_deleted == true
  end

  after_commit :event_notification, on: :create

  def image_file=(file)
    return if file.blank?

    image.attach(io: file[:tempfile],
                 filename: file[:filename],
                 content_type: file[:type])
  end

  def self.event_state(state)
    case state
    when 'upcoming'
      where('start_date > ?', Date.today)
    when 'running'
      where('start_date <= :date_value and end_date >= :date_value', { date_value: Date.today })
    when 'completed'
      where('end_date < ?', Date.today)
    end
  end

  def self.event_in_date_range(start_date, end_date)
    where('(date(start_date) = :start_date or date(end_date) = :end_date
          or date(start_date) < :start_date and date(end_date) >= :start_date)
          or (date(start_date) > :start_date and date(start_date) <= :end_date)
          or (date(end_date) > :end_date and date(start_date) <= :end_date)
          or (date(end_date) < :end_date and date(end_date) >= :start_date)', start_date:, end_date:)
  end

  after_commit on: :create do
    if is_local == true
      Staff.admin.all.each do |admin_staff|
        notification = Notification.create_notification(self, admin_staff,
                                                        I18n.t('Local Event Is Created'),
                                                        I18n.t('Local Event Is Created', locale: :bn),
                                                        I18n.t('Local Event Is Created Successfully'),
                                                        I18n.t('Local Event Is Created Successfully', locale: :bn))
        notification.save
      end
    end
  end

  def event_notification
    if is_local?
      users = libraries.last.users
      users.each do |user|
        notification = Notification.create_notification(self,
                                         user,
                                         I18n.t('Event Started In Your Library'),
                                         I18n.t('Event Started In Your Library', locale: :bn),
                                         I18n.t('Event Is Going live In Your Library'),
                                         I18n.t('Event Is Going live In Your Library', locale: :bn))
        notification.save
      end

    elsif is_local == false
      User.all.each do |user|
        notification = Notification.create_notification(self,
                                         user,
                                         I18n.t('Global Event Is Started'),
                                         I18n.t('Global Event Is Started', locale: :bn),
                                         I18n.t('Global Event Is Started In All Library'),
                                         I18n.t('Global Event Is Started In All Library', locale: :bn))
        notification.save
      end
    end
  end


  private

  def set_slug
    slug_title = title.parameterize
    self.slug = Event.find_by(slug: slug_title).present? ? "#{slug_title}-#{Event.all.count + 1}" : slug_title
  end
end

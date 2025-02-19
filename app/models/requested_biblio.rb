# frozen_string_literal: true

class RequestedBiblio < ApplicationRecord
  serialize :authors_name, Array
  serialize :biblio_subjects_name, Array

  belongs_to :user, optional: true
  belongs_to :library, optional: true
  belongs_to :updated_by, polymorphic: true, optional: true
  belongs_to :created_by, polymorphic: true, optional: true
  has_many :biblio_subject_requested_biblios, dependent: :restrict_with_exception
  has_many :author_requested_biblios, dependent: :restrict_with_exception
  has_many :authors, through: :author_requested_biblios
  has_many :biblio_subjects, through: :biblio_subject_requested_biblios
  has_many :notifications, as: :notificationable, dependent: :destroy


  accepts_nested_attributes_for :author_requested_biblios, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :biblio_subject_requested_biblios, allow_destroy: true, reject_if: :all_blank

  has_one_attached :image do |attachable|
    attachable.variant :desktop_cart, resize_to_limit: [183, 260]
    attachable.variant :tab_cart, resize_to_limit: [150, 194]
    attachable.variant :mobile_cart, resize_to_limit: [156, 230]
    attachable.variant :desktop_large, resize_to_limit: [500, 620]
    attachable.variant :tab_large, resize_to_limit: [150, 194]
    attachable.variant :mobile_large, resize_to_limit: [250, 320]
  end

  after_create :book_demands_placed
  after_update :possible_availability_notification

  def image_file=(file)
    return if file.blank?

    image.attach(io: file[:tempfile],
                 filename: file[:filename],
                 content_type: file[:type])
  end

  def possible_availability_notification
    if self.possible_availability_at.present?
      notification = Notification.create_notification(self, user,
                                                      I18n.t('The possible book availability date is %{date}', date: possible_availability_at),
                                                      I18n.t('The possible book availability date is %{date}', locale: :bn, date: possible_availability_at),
                                                      I18n.t('The possible book availability date is %{date}', date: possible_availability_at),
                                                      I18n.t('The possible book availability date is %{date}', locale: :bn, date: possible_availability_at))
      notification.save
    else
      notification = Notification.create_notification(self, user,
                                                      I18n.t('Possible date will be decided later'),
                                                      I18n.t('Possible date will be decided later', locale: :bn),
                                                      I18n.t('Possible date will be decided later'),
                                                      I18n.t('Possible date will be decided later', locale: :bn))
      notification.save
    end
  end

  def book_demands_placed

    Staff.admin.all.each do |admin_staff|
      notification = Notification.create_notification(self, admin_staff,
                                                      I18n.t('Book Demand Placed'),
                                                      I18n.t('Book Demand Placed', locale: :bn),
                                                      I18n.t('Book Demand Placed successfully'),
                                                      I18n.t('Book Demand Placed successfully', locale: :bn))
      notification.save
    end
  end
end

# frozen_string_literal: true

class Album < ApplicationRecord
  include SearchableEngBanglaTitle

  audited
  belongs_to :event, optional: true
  belongs_to :library, optional: true
  belongs_to :event, optional: true
  has_many :album_items, dependent: :destroy
  has_many :notifications, as: :notificationable, dependent: :destroy
  accepts_nested_attributes_for :album_items, allow_destroy: true

  validates :title, :bn_title, presence: true
  validates_uniqueness_of :title, :bn_title

  before_create :set_slug

  scope :visible, -> { where(is_visible: true) }

  enum album_type: { photo: 0, video: 1 }
  enum status: { pending: 0, approved: 1, rejected: 2 }
  has_one_attached :image do |attachable|
    attachable.variant :desktop_cart, resize_to_limit: [183, 260]
    attachable.variant :tab_cart, resize_to_limit: [150, 194]
    attachable.variant :mobile_cart, resize_to_limit: [156, 230]
    attachable.variant :desktop_large, resize_to_limit: [500, 620]
    attachable.variant :tab_large, resize_to_limit: [150, 194]
    attachable.variant :mobile_large, resize_to_limit: [250, 320]
  end

  after_create :gallery_album_add_requests

  def image_file=(file)
    return if file.blank?

    image.attach(io: file[:tempfile],
                 filename: file[:filename],
                 content_type: file[:type])
  end

  def set_slug
    self.slug = title.to_s.parameterize
  end

  def gallery_album_add_requests
    Staff.admin.all.each do |admin_staff|
      notification = Notification.create_notification(self, admin_staff,
                                                      I18n.t('Gallery album requests'),
                                                      I18n.t('Gallery album requests', locale: :bn),
                                                      I18n.t('Request Placed To Add Gallery Album'),
                                                      I18n.t('Request Placed To Add Gallery Album', locale: :bn))
      notification.save
    end
  end

end

# frozen_string_literal: true

class Banner < ApplicationRecord
  audited
  belongs_to :page_type
  scope :not_deleted, -> { where(is_deleted: false) }
  scope :visible, -> { where(is_visible: true) }
  validates :position, presence: true, numericality: { greater_than: 0 }
  validates_uniqueness_of :slug, :title, :bn_title
  validates_uniqueness_of :position, scope: :page_type_id
  has_one_attached :image do |attachable|
    attachable.variant :desktop_cart, resize_to_limit: [183, 260]
    attachable.variant :tab_cart, resize_to_limit: [150, 194]
    attachable.variant :mobile_cart, resize_to_limit: [156, 230]
    attachable.variant :desktop_large, resize_to_limit: [500, 620]
    attachable.variant :tab_large, resize_to_limit: [150, 194]
    attachable.variant :mobile_large, resize_to_limit: [250, 320]
  end

  before_create :set_slug

  def image_file=(file)
    return if file.blank?

    image.attach(io: file[:tempfile],
                 filename: file[:filename],
                 content_type: file[:type])
  end

  private

  def set_slug
    slug = title.to_s.parameterize
    self.slug = Banner.find_by(slug:).present? ? "#{slug}-#{Banner.all.count + 1}" : slug
  end
end

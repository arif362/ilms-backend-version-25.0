# frozen_string_literal: true

class HomepageSlider < ApplicationRecord
  audited
  validates_uniqueness_of :title
  validates :serial_no, presence: true, numericality: { greater_than: 0 }
  validates_uniqueness_of :serial_no, scope: :is_visible
  scope :not_deleted, -> { where(is_deleted: false) }
  scope :visible, -> { where(is_visible: true) }
  has_one_attached :image do |image|
    image.variant :desktop_large, resize_to_limit: [500, 620]
    image.variant :tab_large, resize_to_limit: [150, 194]
    image.variant :mobile_large, resize_to_limit: [250, 320]
  end

  def image_file=(file)
    return if file.blank?

    image.attach(io: file[:tempfile],
                 filename: file[:filename],
                 content_type: file[:type])
  end
end

# frozen_string_literal: true

class Memorandum < ApplicationRecord
  has_many :memorandum_publishers
  has_many :purchase_orders, dependent: :restrict_with_exception
  has_many :po_line_items, through: :purchase_orders
  has_many :publishers, through: :memorandum_publishers
  has_one_attached :image

  validates :memorandum_no, presence: true, uniqueness: true
  validates :start_date, :end_date, :start_time, :end_time, :tender_session, presence: true
  validate :valid_tender_session_format
  validates :image, blob: { content_type: %w[image/jpg image/jpeg image/png image/webp application/pdf],
                            size_range: 1..3.megabytes }


  scope :not_deleted, -> { where(is_deleted: false) }
  scope :is_visible, -> { where(is_visible: true) }

  def valid_tender_session_format
    unless tender_session.match?(/\A\d{4}-\d{4}\z/)
      errors.add(:tender_session, 'is not in the correct format (####-####)')
      return
    end

    year_range = tender_session.split('-').map(&:to_i)
    return if year_range[1] == year_range[0] + 1

    errors.add(:tender_session, 'second year should be one greater than the first year')
  end

  def image_file=(file)
    return if file.blank?

    image.attach(io: file[:tempfile],
                 filename: file[:filename],
                 content_type: file[:type])
  end
end

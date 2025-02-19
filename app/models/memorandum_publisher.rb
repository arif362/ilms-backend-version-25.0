# frozen_string_literal: true

class MemorandumPublisher < ApplicationRecord
  belongs_to :publisher
  belongs_to :memorandum
  has_many :publisher_biblios, dependent: :restrict_with_exception
  has_many :goods_receipts, dependent: :restrict_with_exception
  has_many :department_biblio_items, dependent: :restrict_with_exception
  has_one :purchase_order

  validate :validate_memorandum_date, on: :create

  scope :submitted, -> { where(is_final_submitted: true) }
  scope :shortlisted, -> { where(is_shortlisted: true) }

  def has_purchase_order?
    purchase_order.present?
  end


  after_create :save_track_no

  def validate_memorandum_date
    errors.add(:last_submission_date, ' is over') unless memorandum.last_submission_date >= Date.today
  end

  private

  def save_track_no
    self.track_no = id.to_s.rjust(8, '0').to_s
  end
end

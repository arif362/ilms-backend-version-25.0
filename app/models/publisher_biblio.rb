# frozen_string_literal: true

class PublisherBiblio < ApplicationRecord
  belongs_to :memorandum_publisher
  has_one :publisher, through: :memorandum_publisher
  has_one :memorandum, through: :memorandum_publisher
  has_many :goods_receipts, dependent: :restrict_with_exception
  has_many :department_biblio_items, dependent: :restrict_with_exception

  validates_uniqueness_of :title, :isbn, scope: :memorandum_publisher_id
  validates :publisher_phone, length: { is: 11 },
                              numericality: { only_integer: true },
                              format: { with: /(\A(\+88|0088)?(01)[3456789](\d){8})\z/,
                                        message: 'Not a valid phone number' },
                              if: -> { publisher_phone.present? }

  validate :validate_not_submitted, :validate_memorandum_date, on: :create

  enum paper_type: { white_paper: 0, newspaper: 1 }
  enum binding_type: { hard_binding: 0, paper_binding: 1 }

  def validate_not_submitted
    return unless memorandum_publisher&.is_final_submitted

    errors.add(:is_final_submitted, 'is true cannot add biblio anymore')
    raise ActiveRecord::RecordInvalid, self
  end

  def validate_memorandum_date
    memorandum_publisher.validate_memorandum_date
  end
end

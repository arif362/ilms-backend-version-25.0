# frozen_string_literal: true

class Publisher < ApplicationRecord
  belongs_to :user
  has_many :memorandum_publishers
  has_many :publisher_biblios, through: :memorandum_publishers

  has_many :purchase_orders, dependent: :restrict_with_exception
  has_many :po_line_items, through: :purchase_orders
  has_many :goods_receipts, dependent: :restrict_with_exception
  has_many :department_biblio_items, dependent: :restrict_with_exception

  validates :publication_name, :address, presence: true

  after_create :generate_track_no

  private

  def generate_track_no
    update!(track_no: id.to_s.rjust(5, '0'))
  end
end

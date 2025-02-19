class PoLineItem < ApplicationRecord
  belongs_to :purchase_order
  belongs_to :publisher_biblio
  has_many :department_biblio_items, dependent: :restrict_with_exception
  has_many :goods_receipts, dependent: :restrict_with_exception

  scope :with_goods_receipts, -> { joins(:goods_receipts).distinct }


  def received_quantity
    goods_receipts.sum(:quantity)
  end

  def has_accession_number_quantity
    department_biblio_items.where.not(central_accession_no: nil).count
  end

  def not_sent_to_library_quantity
    department_biblio_items.where(library_id: nil).count
  end
end

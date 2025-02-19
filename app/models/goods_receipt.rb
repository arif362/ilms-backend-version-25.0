class GoodsReceipt < ApplicationRecord
  belongs_to :purchase_order
  belongs_to :publisher
  belongs_to :memorandum_publisher
  belongs_to :publisher_biblio
  belongs_to :po_line_item
  belongs_to :updated_by, polymorphic: true
  has_many :department_biblio_items, dependent: :restrict_with_exception

  after_create :update_purchase_order_status, :update_po_line_update
  after_commit :create_department_biblios

  scope :not_deleted, -> { where(deleted_at: nil) }

  def self.unique_by_po_line_item_id
    select(
      "MAX(id) AS id,
      po_line_item_id,
      MAX(purchase_order_id) AS purchase_order_id,
      MAX(publisher_id) AS publisher_id,
      MAX(memorandum_publisher_id) AS memorandum_publisher_id,
      MAX(publisher_biblio_id) AS publisher_biblio_id,
      MAX(quantity) AS quantity,
      MAX(price) AS price,
      MAX(sub_total) AS sub_total,
      MAX(bar_code) AS bar_code,
      MAX(purchase_code) AS purchase_code,
      MAX(created_by_id) AS created_by_id,
      MAX(created_by_type) AS created_by_type,
      MAX(updated_by_id) AS updated_by_id,
      MAX(updated_by_type) AS updated_by_type,
      MAX(deleted_at) AS deleted_at,
      MAX(created_at) AS created_at,
      MAX(updated_at) AS updated_at"
    )
      .group(:po_line_item_id)
  end

  def received_quantity
    self.class.where(po_line_item_id:).sum(:quantity)
  end

  def has_accession_number_quantity
    department_biblio_items.where.not(central_accession_no: nil).count
  end

  def not_sent_to_library_quantity
    department_biblio_items.where(library_id: nil).count
  end

  private
  def update_purchase_order_status
    return unless purchase_order.purchase_order_status.sent? || purchase_order.purchase_order_status.partially_received?

    purchase_order.update!(purchase_order_status: PurchaseOrderStatus.get_status(:partially_received))
  end

  def update_po_line_update
    return if po_line_item.received_at.present?

    all_quantity = po_line_item.goods_receipts.sum(:quantity)

    return unless quantity == po_line_item.quantity || all_quantity == po_line_item.quantity

    po_line_item.update!(received_at: DateTime.now)

    update_purchase_order
  end

  def update_purchase_order
    line_items = purchase_order.po_line_items
    received_line_items_count = line_items.where.not(received_at: nil).count

    return unless received_line_items_count == line_items.count

    purchase_order.update!(purchase_order_status: PurchaseOrderStatus.get_status(:received))
  end

  def create_department_biblios
    Admin::DepartmentBiblioItemCreateJob.perform_later(self)
  end


end

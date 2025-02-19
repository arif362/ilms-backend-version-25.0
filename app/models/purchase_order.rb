class PurchaseOrder < ApplicationRecord
  belongs_to :memorandum
  belongs_to :publisher
  belongs_to :memorandum_publisher, optional: true
  belongs_to :purchase_order_status
  belongs_to :updated_by, polymorphic: true, optional: true

  has_many :po_status_change, dependent: :destroy
  has_many :po_line_items, dependent: :restrict_with_exception
  has_many :goods_receipts, dependent: :restrict_with_exception
  has_many :department_biblio_items, dependent: :restrict_with_exception

  before_create :has_publisher_biblio
  after_create  :create_po_status_change
  after_update :create_po_status_change, :send_email_to_publisher

  def has_publisher_biblio
    return if publisher.publisher_biblios.present?

    error!('publisher does not has any biblio', HTTP_CODE[:NOT_ACCEPTABLE])
  end

  scope :not_deleted, -> { where(deleted_at: nil) }

  # def create_po_line_items
  #   publisher_biblios = publisher.publisher_biblios
  #   if publisher_biblios.nil?
  #     raise ActiveRecord::Rollback, 'Publisher biblio is not found in this memorandum publisher'
  #   end
  #
  #   publisher_biblios.each do |publisher_biblio|
  #     po_line_item = po_line_items.build(publisher_biblio_id: publisher_biblio.id,
  #                                        quantity: publisher_biblio.quantity,
  #                                        price: publisher_biblio.price,
  #                                        sub_total: sub_total_calculation(publisher_biblio),
  #                                        bar_code: publisher_biblio.isbn)
  #     po_line_item.save!
  #   end
  # end

  def sub_total_calculation(price, quantity)
    price * quantity.to_i
  end

  def create_po_status_change
    po_status_change.create!(purchase_order_status_id: purchase_order_status.id, changed_by: updated_by)
  end

  def send_email_to_publisher
    return unless publisher.user.email.present?

    PublisherMailer.send_mail_to_publisher(publisher, purchase_order_status.publisher_status).deliver_later
  end

end

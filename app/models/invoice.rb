class Invoice < ApplicationRecord
  audited
  enum invoice_type: { security_money: 0, library_card: 1, third_party: 2, fine: 3, security_money_withdraw: 4, return_from_home: 5 }
  enum invoice_status: { pending: 0, paid: 1, partial: 2 }

  validates :invoice_amount, presence: true, numericality: { greater_than: 0 }

  belongs_to :invoiceable, polymorphic: true
  belongs_to :user
  has_many :return_order, dependent: :destroy
  has_many :invoices_payments, dependent: :restrict_with_exception
  has_many :payments, through: :invoices_payments, dependent: :restrict_with_exception
  has_one :security_money, dependent: :destroy
  has_many :notifications, as: :notificationable, dependent: :destroy

  after_create :send_notification
  after_update :trigger_events

  after_commit on: :create do
    if invoiceable.is_a?(Circulation) || invoiceable.is_a?(LostDamagedBiblio)
      Lms::FineInvoice::SendInvoiceJob.perform_later(self)
    end
  end

  after_commit on: :update do
    Lms::FinePaymentConfirmPay::FinePaymentConfirmJob.perform_later(self) if payments&.last&.nagad? && fine? && paid?
  end

  def paid_amount
    payments.sum(:amount)
  end

  def backend_id
    id.to_s.rjust(7, '0').to_s
  end

  private

  def send_notification
    Notification.create_notification(self,
                                     user,
                                     I18n.t('invoice'),
                                     I18n.t('invoice', locale: :bn),
                                     "#{I18n.t('Please pay your due invoice amount')}: #{invoice_amount}",
                                     "#{I18n.t('Please pay your due invoice amount')}: #{I18n.t(invoice_amount, 
                                                                                                locale: :bn)}")
  end

  def trigger_events
    return unless paid?

    return unless invoiceable.is_a?(Order)

    invoiceable.update!(order_status: OrderStatus.get_status(:ready_for_pickup))

  end
end

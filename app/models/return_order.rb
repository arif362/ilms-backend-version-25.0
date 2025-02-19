class ReturnOrder < ApplicationRecord
  enum address_type: { present: 0, permanent: 1, others: 2 }
  enum return_type: { return_to_library: 0, return_from_home: 1 }


  belongs_to :user
  belongs_to :library
  belongs_to :division
  belongs_to :district
  belongs_to :thana
  belongs_to :return_status
  has_many :invoices, as: :invoiceable, dependent: :destroy
  has_many :return_items, dependent: :destroy
  has_many :biblio_items, through: :return_items
  has_many :return_status_changes, dependent: :destroy
  has_many :circulations, dependent: :restrict_with_exception
  has_many :notifications, as: :notificationable, dependent: :destroy


  after_create :calculate_total_fine
  after_commit :push_to_lms
  after_save :update_circulation
  after_commit :return_order_invoice_with_notification

  private

  def calculate_total_fine
    update!(total_fine: return_items.sum(:fine_sub_total))
  end

  def update_circulation
    return unless return_status == ReturnStatus.get_status(:collected_by_3pl)

    return_items.each do |item|
      item.circulation.update!(circulation_status: CirculationStatus.get_status(:returned),
                               returned_at: DateTime.now)
    end
  end

  def push_to_lms
    if return_status.initiated?
      Lms::ReturnOrderManagement::CreateReturnOrderJob.perform_later(self, user)
    elsif return_status.collected_by_3pl?
      Lms::ReturnOrderManagement::RoTransitStatusUpdateJob.perform_later(self, user)
    end
  end

  def return_order_invoice_with_notification
    return unless return_status.initiated?

    if return_from_home?
      invoices.create(invoice_type: 'return_from_home', user: self.user, invoice_amount: ENV['SHIPPING_CHARGE_SAME_DISTRICT'].to_i, invoice_status: 'pending')
    end

    notification = Notification.create_notification(self,
                                                    user,
                                                    I18n.t('Return Order placed'),
                                                    I18n.t('Return Order placed', locale: :bn),
                                                    I18n.t('Return Order placed Please wait for the delivery boy'),
                                                    I18n.t('Return Order placed Please wait for the delivery boy', locale: :bn))
    notification.save
  end
end

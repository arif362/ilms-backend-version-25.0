class LostDamagedBiblio < ApplicationRecord
  belongs_to :updated_by, polymorphic: true, optional: true
  belongs_to :created_by, polymorphic: true, optional: true
  belongs_to :member, optional: true
  belongs_to :biblio_item
  belongs_to :biblio
  belongs_to :library
  belongs_to :circulation, optional: true
  has_one :invoice, as: :invoiceable, dependent: :destroy
  has_many :notifications, as: :notificationable, dependent: :destroy

  validate :check_invoiceable, if: :patron?

  enum request_type: { library: 0, patron: 1 }
  enum status: { damaged: 0, lost: 1, prun: 2 }

  after_create :make_invoice, :create_notification, :update_circulation, if: :patron?

  private

  def make_invoice
    create_invoice!(invoice_type: Invoice.invoice_types[:fine], user_id: member.user_id, invoice_amount: biblio_item.price.to_i * 2)
  end

  def create_notification
    Notification.create_notification(self,
                                     member.user,
                                     I18n.t('Damage Request Created'),
                                     I18n.t('Damage Request Created', locale: :bn),
                                     I18n.t('You have successfully created damaged request'),
                                     I18n.t('You have successfully created damaged request', locale: :bn))
    # notifications.create!(notifiable: member.user, message: 'You have successfully created damaged request',
    #                       message_bn: 'BN: You have successfully created damaged request')
  end

  def update_circulation
    circulation_status = lost? ? 'lost' : 'damaged_returned'
    circulation.update!(circulation_status_id: CirculationStatus.get_status(CirculationStatus.status_keys[circulation_status.to_sym]).id)
  end

  def check_invoiceable
    return if library?
    return if member.present? && circulation.present?

    errors.add(:base, :member_id_and_circulation_id,
               message: 'member id and circulation id must be present')
  end
end

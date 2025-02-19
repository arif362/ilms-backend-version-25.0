class SecurityMoneyRequest < ApplicationRecord
  audited

  belongs_to :updated_by, polymorphic: true, optional: true
  belongs_to :created_by, polymorphic: true, optional: true
  belongs_to :user
  belongs_to :library
  belongs_to :created_by, polymorphic: true
  belongs_to :updated_by, polymorphic: true
  has_many :money_request_status_changes, dependent: :restrict_with_exception
  has_many :notifications, as: :notificationable, dependent: :destroy
  has_many :invoices, as: :invoiceable, dependent: :restrict_with_exception

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validate :check_phone

  enum status: { pending: 0, approved: 1, rejected: 2, available_to_withdraw: 3, withdrawn: 4 }
  enum payment_method: { pickup_from_library: 0, nagad_payment: 1 }

  before_save :track_status_changes
  after_save :update_security_money_status, :deactivate_member, if: :withdrawn?
  after_save :lms_smr_online_withdraw, if: :withdrawn? && :nagad_payment?
  after_commit :create_lms_smr, on: :create

  def validate_status_update(new_status)
    case new_status
    when 'approved' then status == 'pending'
    when 'rejected' then status == 'pending'
    when 'available_to_withdraw' then status == 'approved'
    when 'withdrawn' then status == 'available_to_withdraw'
    end
  end

  private

  def check_phone
    return if pickup_from_library?

    errors.add(:base, 'phone must be exist for nagad payment') if phone.nil?
  end

  def track_status_changes
    money_request_status_changes.build(status:)
    add_invoice if approved?
    create_notification
  end

  def update_security_money_status
    user.security_moneys.update_all(status: :withdraw)
  end

  def deactivate_member
    user.member.update!(is_active: false)
  end

  def create_notification
    # TO-DO: should move the bangla text into yaml file from here
    case status
    when 'pending'
      Notification.create_notification(self, user,
                                       I18n.t('request sent to library'),
                                       I18n.t('request sent to library', locale: :bn),
                                       I18n.t('Your security money request has been sent to library please wait for the approval'),
                                       I18n.t('Your security money request has been sent to library please wait for the approval',locale: :bn))
    when 'approved'
      Notification.create_notification(self, user,
                                       I18n.t('Security money request approved'),
                                       I18n.t('Security money request approved', locale: :bn),
                                       I18n.t('Your security money request has been approved'),
                                       I18n.t('Your security money request has been approved', locale: :bn))
    when 'rejected'
      Notification.create_notification(self, user,
                                       I18n.t('Your security money request has been rejected'),
                                       I18n.t('Your security money request has been rejected', locale: :bn),
                                       I18n.t('Your security money request has been rejected'),
                                       I18n.t('Your security money request has been rejected', locale: :bn))
    end
  end

  def add_invoice
    invoices.build(invoice_type: Invoice.invoice_types[:security_money_withdraw], user_id:, invoice_amount: amount)
  end

  def create_lms_smr
    Lms::SecurityMoneyWithdrawalManage::CreateSecurityMoneyWithdrawJob.perform_later(self, user) if created_by_type == 'User'
  end

  def lms_smr_online_withdraw
    Lms::SecurityMoneyWithdrawalManage::UpdateSecurityMoneyWithdrawJob.perform_later(self, user)
  end
end

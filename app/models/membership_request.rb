class MembershipRequest < ApplicationRecord
  serialize :notes, Array
  enum request_type: { initial: 0, renew: 1, upgrade: 2 }
  enum status: { pending: 0, payment_pending: 1, rejected: 2, correction_required: 3, correction_submitted: 4,
                 completed: 5, cancelled: 6 }

  belongs_to :user
  belongs_to :request_detail, optional: true
  belongs_to :updated_by, polymorphic: true, optional: true
  belongs_to :created_by, polymorphic: true, optional: true
  has_one :member
  has_many :invoices, as: :invoiceable
  has_many :otps, as: :otp_able, dependent: :destroy
  has_many :notifications, as: :notificationable, dependent: :destroy


  accepts_nested_attributes_for :request_detail

  scope :processing, -> { where(status: %w[pending payment_pending correction_required correction_submitted]) }

  before_update :add_invoice
  after_commit :lms_update_membership_request, on: :update
  after_save :membership_notification

  private

  def membership_notification
    case self.status
    when 'pending'
      Notification.create_notification(self,
                                       user,
                                       I18n.t('Your Membership Request Submitted'),
                                       I18n.t('Your Membership Request Submitted', locale: :bn),
                                       I18n.t('Your have successfully Submitted membership'),
                                       I18n.t('Your have successfully Submitted membership', locale: :bn))
    when 'payment_pending'

      Notification.create_notification(self,
                                       user,
                                       I18n.t('Your Membership Request Approved'),
                                       I18n.t('Your Membership Request Approved', locale: :bn),
                                       I18n.t('Your membership request has been Approved, Please complete your payment process'),
                                       I18n.t('Your membership request has been Approved, Please complete your payment process', locale: :bn))

    when 'rejected'

      Notification.create_notification(self,
                                       user,
                                       I18n.t('Your Membership Request Rejected'),
                                       I18n.t('Your Membership Request Rejected', locale: :bn),
                                       I18n.t('Your membership Request Has Been Rejected'),
                                       I18n.t('Your membership Request Has Been Rejected', locale: :bn))

    when 'correction_required'

      Notification.create_notification(self,
                                       user,
                                       I18n.t('Your Membership Request Require Correction'),
                                       I18n.t('Your Membership Request Require Correction', locale: :bn),
                                       I18n.t('Your Membership Request Details Require Correction'),
                                       I18n.t('Your Membership Request Details Require Correction', locale: :bn))

    when 'correction_submitted'

      Notification.create_notification(self,
                                       user,
                                       I18n.t('Membership Request Correction Submitted'),
                                       I18n.t('Membership Request Correction Submitted', locale: :bn),
                                       I18n.t('Your Membership Request Correction successfully Submitted'),
                                       I18n.t('Your Membership Request Correction successfully Submitted', locale: :bn))

    when 'completed'

      Notification.create_notification(self,
                                       user,
                                       I18n.t('Congratulation, Your Now Member'),
                                       I18n.t('Congratulation, Your Now Member', locale: :bn),
                                       I18n.t('Congratulation, Your Membership Request Successfully Completed'),
                                       I18n.t('Congratulation, Your Membership Request Successfully Completed', locale: :bn))

    when 'cancelled'

      Notification.create_notification(self,
                                       user,
                                       I18n.t('Membership Request Cancelled'),
                                       I18n.t('Membership Request Cancelled', locale: :bn),
                                       I18n.t('Membership Request Has Been Cancelled'),
                                       I18n.t('Membership Request Has Been Cancelled', locale: :bn))

    end

  end

  def add_invoice
    return unless payment_pending?

    invoices.build(invoice_type: Invoice.invoice_types[:security_money],
                   user_id:,
                   invoice_amount:,
                   shipping_charge:,
                   shipping_charge_vat:)
  end

  def invoice_amount
    if request_type == 'initial'
      ENV["#{request_detail.membership_category.upcase}_MBR_SECURITY_MONEY"].to_i + third_party_invoice_amount
    elsif request_type == 'upgrade'
      upgrade_invoice_amount + third_party_invoice_amount
    end
  end

  def upgrade_invoice_amount
    upgrade_plan = request_detail.membership_category
    current_plan = user&.member&.membership_category
    ENV["#{upgrade_plan.upcase}_MBR_SECURITY_MONEY"].to_i - ENV["#{current_plan.upcase}_MBR_SECURITY_MONEY"].to_i
  end

  def third_party_invoice_amount
    shipping_charge + shipping_charge_vat
  end

  def shipping_charge
    charge = request_detail.delivery_thana == request_detail.library.thana ? ENV['SHIPPING_CHARGE_SAME_DISTRICT'].to_i : ENV['SHIPPING_CHARGE_OTHER_DISTRICT'].to_i
    request_detail.home_delivery? ? charge : 0
  end

  def shipping_charge_vat
    request_detail.home_delivery? ? (shipping_charge * ENV['SHIPPING_CHARGE_VAT'].to_f).round : 0
  end

  def lms_update_membership_request
    return unless saved_changes.key?('status') && status == 'correction_submitted'

    Lms::MembershipManage::UpdateMembershipJob.perform_later(self, user)
  end
end

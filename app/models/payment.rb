# frozen_string_literal: true

class Payment < ApplicationRecord

  belongs_to :member, optional: true
  belongs_to :user
  belongs_to :created_by, polymorphic: true, optional: true
  belongs_to :updated_by, polymorphic: true, optional: true
  has_many :invoices_payments, dependent: :destroy
  has_many :invoices, through: :invoices_payments, dependent: :restrict_with_exception



  validates :amount, presence: true, numericality: { greater_than: 0 }

  enum payment_type: { cash: 0, online: 1, nagad: 2 }
  enum status: { pending: 0, success: 1, failed: 2, cancelled: 3 }
  enum transaction_type: { in_coming: 0, out_going: 1 }
  enum purpose: { security_money: 0, library_card: 1, third_party: 2, fine: 3, security_money_withdraw: 4,
                  return_from_home: 5 }

  after_update :complete_invoice, :add_member, :add_security_money, :complete_membership_request, if: :success?
  after_commit :create_lms_security_money, on: :update, if: :nagad? && :security_money? && :success?


  def backend_id
    id.to_s.rjust(7, '0').to_s
  end

  private

  def complete_invoice
    invoices.each do |invoice|
      if invoice.paid_amount >= invoice.invoice_amount
        invoice.update!(invoice_status: Invoice.invoice_statuses[:paid])
      elsif invoice.paid_amount.positive?
        invoice.update!(invoice_status: Invoice.invoice_statuses[:partial])
      end
    end
  end

  def add_member
    return unless invoice_id.present? && invoices.last.invoiceable.class.to_s == 'MembershipRequest'

    user_member = user&.member.present? ? user&.member : build_member(member_params)
    if request_detail.membership_request.request_type == 'upgrade'
      update_member_info(user_member)
      upgrade_library_card(user_member)
    end
    attach_member_images(user_member)
    user_member.assign_attributes(is_active: true, activated_at: DateTime.now,
                                  expire_date: DateTime.now + ENV['MEMBERSHIP_EXPIRY_MONTHS'].to_i.month,
                                  updated_by:,
                                  membership_request_id: invoices.last.invoiceable.id,
                                  user_id:,
                                  created_by:)
    user_member.save!
  end

  def attach_member_images(user_member)
    image_files = %w[profile nid_front nid_back birth_certificate student_id verification_certificate]
    image_files.each do |image_file|
      next if request_detail.send("#{image_file}_image_attachment").blank?

      image_attachment = "#{image_file}_image_attachment"
      user_member.public_send("#{image_attachment}=", request_detail.send(image_attachment))
    end
  end

  def update_member_info(user_member)
    case request_detail.membership_category
    when 'student'
      user_member.assign_attributes(student_class: request_detail.student_class, student_section: request_detail.student_section,
                                    student_id: request_detail.student_id)

    when 'general'
      user_member.assign_attributes(profession: request_detail.profession)
    end
    user_member.assign_attributes(institute_name: request_detail.institute_name,
                                  institute_address: request_detail.institute_address,
                                  membership_category: request_detail.membership_category,
                                  identity_type: request_detail.identity_type,
                                  identity_number: request_detail.identity_number)
  end

  def add_security_money
    return unless security_money?

    user.reload
    user.security_moneys.create!(invoice_id:,
                                 member: user.member,
                                 library: user.member.library,
                                 amount:,
                                 payment_method: payment_type)
  end

  def request_detail
    invoices.last.invoiceable.request_detail
  end

  def member_params
    request_detail.attributes.except('id', 'status', 'requested_by_id', 'created_at', 'updated_at', 'updated_at',
                                     'card_delivery_type', 'delivery_address_type', 'recipient_name', 'recipient_phone',
                                     'delivery_address', 'delivery_division_id', 'delivery_district_id',
                                     'delivery_thana_id', 'note')
  end

  def complete_membership_request
    user.member.membership_request.completed!
  end

  def create_lms_security_money
    Lms::CreateSecurityMoneyJob.perform_later(self, user) if security_money?
  end

  def upgrade_library_card(user_member)
    user_member.library_cards.active.update_all(is_active: false)
    request_details = user.membership_requests.last.request_detail
    # create new card for updated membership category
    user_member.library_cards.create!(
      name: request_details.full_name,
      issued_library_id: request_details.library_id,
      issue_date: Time.current,
      expire_date: Time.current.next_year(100),
      membership_category: request_details.membership_category,
      card_status_id: CardStatus.find_by(status_key: CardStatus.status_keys[:pending]).id,
      delivery_type: request_details.card_delivery_type,
      address_type: request_details.delivery_address_type,
      recipient_name: request_details.recipient_name,
      recipient_phone: request_details.recipient_phone,
      delivery_address: request_details.delivery_address,
      division_id: request_details.delivery_division_id,
      district_id: request_details.delivery_district_id,
      thana_id: request_details.delivery_thana_id
    )
  end
end

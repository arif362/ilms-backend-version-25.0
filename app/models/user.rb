# frozen_string_literal: true
class User < ApplicationRecord
  include AuthValidation

  # Validation
  validates_presence_of :full_name
  validates :email, allow_blank: true, uniqueness: true,
                    format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/, message: 'format is invalid' },
                    on: :create
  validates :image, blob: { content_type: %w[image/jpg image/jpeg image/png image/webp], size_range: 1..3.megabytes }


  # Associations
  belongs_to :updated_by, polymorphic: true, optional: true
  belongs_to :created_by, polymorphic: true, optional: true
  has_one :member
  has_one :publisher
  has_many :authorization_keys, as: :authable, dependent: :destroy
  has_many :otps, as: :otp_able, dependent: :destroy
  has_many :library_entry_logs, as: :entryable
  has_many :reviews, dependent: :restrict_with_exception
  has_many :membership_requests
  has_many :saved_addresses
  has_many :orders
  has_many :line_items, through: :orders
  has_many :biblio_wishlists
  has_many :notifications, as: :notifiable
  has_many :complains
  has_many :payments, dependent: :restrict_with_exception
  has_many :phone_change_requests, dependent: :restrict_with_exception
  has_many :requested_biblios, as: :updated_by
  has_many :requested_biblios, as: :created_by
  has_one :cart
  has_many :event_registrations, dependent: :restrict_with_exception
  has_many :book_transfer_orders, dependent: :restrict_with_exception
  has_many :library_transfer_orders, dependent: :restrict_with_exception
  has_many :requested_biblios, dependent: :restrict_with_exception
  has_many :user_qr_codes, dependent: :restrict_with_exception
  has_many :invoices, dependent: :restrict_with_exception
  has_many :security_moneys, dependent: :restrict_with_exception
  has_many :security_money_requests, dependent: :restrict_with_exception
  has_many :return_orders, dependent: :restrict_with_exception
  has_many :account_deletion_requests, dependent: :restrict_with_exception
  has_many :user_suggestions, dependent: :restrict_with_exception
  has_many :lms_logs, as: :user_able
  has_many :suggested_biblios
  has_one_attached :image do |attachable|
    attachable.variant :desktop_large, resize_to_limit: [1240, 480]
    attachable.variant :desktop_cart, resize_to_limit: [1240, 480]
    attachable.variant :tab_large, resize_to_limit: [620, 240]
    attachable.variant :tab_cart, resize_to_limit: [620, 240]
    attachable.variant :mobile_large, resize_to_limit: [500, 200]
    attachable.variant :mobile_cart, resize_to_limit: [500, 200]
  end
  has_many :physical_reviews, dependent: :restrict_with_exception
  has_many :extend_requests, dependent: :restrict_with_exception

  # Enum
  enum gender: { male: 0, female: 1, other: 2 }
  # Scopes
  scope :active, -> { where(is_active: true) }

  after_commit :lms_change_phone, :remove_authorization_key, on: :update
  after_create :user_registration_mail

  # Methods
  def registered_name
    full_name
  end

  def unique_id
    "R-#{id.to_s.rjust(8, '0')}"
  end

  def self.search_unique_id_or_phone(search_term)
    where('phone like ? OR id like ?', "%#{search_term}%", search_term.to_i)
  end

  def has_incomplete_orders
    orders.with_status(OrderStatus.status_keys.keys - OrderStatus::FINISHED_STATUSES).count.positive?
  end

  def items_on_hand
    exclude_statuses = OrderStatus::NOT_ON_HAND_STATUSES | OrderStatus::FINISHED_STATUSES
    order_items_count = line_items.includes(order: :order_status).where('order_statuses.status_key': OrderStatus.status_keys.keys - exclude_statuses).count
    circulation_items_count = member.circulations.where(circulation_status: CirculationStatus.get_status(:borrowed)).count
    order_items_count + circulation_items_count
  end

  def membership?
    (member&.is_active && member.expire_date >= DateTime.now) || false
  end

  def publisher?
    publisher.present?
  end

  def current_cart
    cart || create_cart!
  end

  def image_file=(file)
    return if file.blank?

    image.attach(io: file[:tempfile],
                 filename: file[:filename],
                 content_type: file[:type])
  end

  def unique_requested_biblio(params)
    requested_biblios = self.requested_biblios.where(biblio_title: params[:biblio_title],
                              authors_name: params[:authors_name],
                              biblio_subjects_name: params[:biblio_subjects_name],
                              isbn: params[:isbn],
                              publication: params[:publication],
                              edition: params[:edition],
                              volume: params[:volume])
    return if requested_biblios.blank?

    if params[:author_requested_biblios_attributes].present?
      requested_biblios = check_authors(requested_biblios, params[:author_requested_biblios_attributes])
    end
    return unless params[:biblio_subject_requested_biblios_attributes].present? && requested_biblios.present?

    check_subjects(requested_biblios, params[:biblio_subject_requested_biblios_attributes])
  end

  def check_authors(requested_biblios, author_ids)
    requested_biblios.joins(:authors).where(authors: {id: author_ids.map { |hash| hash["author_id"] }})
  end

  def check_subjects(requested_biblios, subject_ids)
    requested_biblios.joins(:biblio_subjects).where(biblio_subjects: { id: subject_ids.map { |hash| hash["biblio_subject_id"] } })
  end

  private

  def lms_change_phone
    return unless member.present? && saved_changes.key?('phone')

    Lms::MemberInfoManage::ChangePhoneJob.perform_later(self)
  end

  def remove_authorization_key
    return unless member.present? && saved_changes.key?('phone')

    authorization_keys.update_all(expiry: Time.now)
  end

  def user_registration_mail
    UserRegistrationMailer.registration_mailer(self).deliver_later
  end
end
